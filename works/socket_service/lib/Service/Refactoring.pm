package Service::Refactoring;

# Refactoring Module
# Author : Romain Raugi

use strict;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

# Rename topic operation
sub renameTopic {
  my ( $key, $web, $topic, $name, $update ) = @_;
  &Service::Trace::log( "Topic $web.$topic renaming attempt by $key" );
  # Normalize web & topic name
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
  # Test parameters existence
  if ( ! &TWiki::Store::topicExists( $web, $topic ) ) { &Service::Trace::log( "Rename operation failed : topic $web.$topic doesn't exist" );return 3; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Rename operation failed : user $key not connected" );return 1; }
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Rename operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  # Initialize
  &Service::Connection::initialize( $login, $web, $topic );
  # Test if name is a WikiWord
  if ( ! &TWiki::isWikiName( $name ) ) { &Service::Trace::log( "Rename operation failed : new name $name isn't a WikiWord" );return 5; }
  # Test destination topic inexistence
  if ( &TWiki::Store::topicExists( $web, $name ) ) { &Service::Trace::log( "Rename operation failed : topic $web.$name already exists" );return 4; }
  # Check permissions
  if ( ! &Service::Topics::testAndGetTopic( $web, $topic, $login, 'rename' ) ) {
    &Service::Trace::log( "Rename operation failed : permissions denied" );
    return 6;
  }
  # Check if topic is locked
  my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $web, $topic );
  if ( ! $lock ) {
    &Service::Trace::log( "Rename operation failed : unable to put lock on topic $web.$topic, already put by $lockUser" );
    return ( 7, $lockUser );
  }
  # Rename
  my $rename_code = &TWiki::Store::renameTopic( $web, $topic, $web, $name, "relink" );
  if ( $rename_code ) { &Service::Trace::log( "Rename error : $rename_code" );return ( 8, $rename_code ); }
  my @updated_topics = ();
  # Update links that refers to
  if ( $update ) {
    @updated_topics = &updateReferences( $key, $login, $web, $topic, $web, $name );
  } elsif ( $update eq 2 ) {
    @updated_topics = &updateReferences( $key, $login, $web, $topic, $web, $name, 1 );
  }
  &Service::Trace::log( "Rename operation succeded, topics @updated_topics updated" );
  return 0;
}

# Move operation
sub moveTopic {
  my ( $key, $srcWeb, $topic, $dstWeb, $parent, $update ) = @_;
  &Service::Trace::log( "Topic $srcWeb.$topic moving attempt by $key" );
  # Test empty parameters
  $parent = $TWiki::mainTopicname if ( $parent eq '' );
  # Normalize webs & topics name
  ( $srcWeb, $topic ) = &TWiki::Store::normalizeWebTopicName( $srcWeb, $topic );
  ( $dstWeb, $parent ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $parent );
  # Test webs and topics existence
  if ( ! &TWiki::Store::topicExists( $srcWeb, $topic ) ) { &Service::Trace::log( "Move operation failed : topic $srcWeb.$topic doesn't exist" );return 3; }
  if ( ! &TWiki::Store::topicExists( $dstWeb, $parent ) ) { &Service::Trace::log( "Move operation failed : topic $dstWeb.$parent doesn't exist" );return 4; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Move operation failed : user $key not connected" );return 1; }
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Move operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  # Initialize
  &Service::Connection::initialize( $login, $srcWeb, $topic );
  # Check permissions
  my $permission = "change";
  $permission = "rename" if ( $srcWeb ne $dstWeb );
  if ( ! &Service::Topics::testAndGetTopic( $srcWeb, $topic, $login, $permission ) ) {
    &Service::Trace::log( "Move operation failed : permissions denied" );
    return 5;
  }
  # Check if topic is locked
  my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $srcWeb, $topic );
  if ( ! $lock ) {
    &Service::Trace::log( "Move operation failed : unable to put lock on topic $srcWeb.$topic, already put by $lockUser" );
    return ( 6, $lockUser );
  }
  # Moving
  if ( $srcWeb ne $dstWeb ) {
    # Error case : topic existence in destination
    if ( &TWiki::Store::topicExists( $dstWeb, $topic ) ) { &Service::Trace::log( "Move operation failed : topic $dstWeb.$topic already exists" );return 7; }
    # Move topic
    my $move_code = &moveTopicOutsideWeb( $srcWeb, $topic, $dstWeb );
    if ( $move_code ) { &Service::Trace::log( "Move error : $move_code" );return ( 8, $move_code ); }
  }
  # Change parent
  my $change_code = &changeParent( $dstWeb, $topic, $parent );
  if ( $change_code ) { &Service::Trace::log( "Error during parent change : $change_code" );return ( 9, $change_code ); }
  # Update links that refers to
  # References need to be updated only if topic has been moved in another web
  my @updated_topics = ();
  if ( $srcWeb ne $dstWeb ) {
    if ( $update ) {
      @updated_topics = &updateReferences( $key, $login, $srcWeb, $topic, $dstWeb, $topic, 1 );
    }
  }
  &Service::Trace::log( "Move operation succeded, topics @updated_topics updated" );
  return 0;
}

sub changeParent {
  # Moving topic must have beeen done before
  my ( $web, $topic, $parent ) = @_;
  my $unlock = "on";
  my $dontNotify = "on";
  my $saveCmd = "";
  # Read topic
  my ( $meta, $text ) = &TWiki::Store::readTopic( $web, $topic );
  # Change parent
  $meta->put( "TOPICPARENT", ( "name" => "$web.$parent" ) );
  my $change_code = &TWiki::Store::saveTopic( $web, $topic, $text, $meta, $saveCmd, $unlock, $dontNotify );
  return 1 if( $change_code );
  return 0;
}

sub moveTopicOutsideWeb {
  my ( $srcWeb, $topic, $dstWeb ) = @_;
  # Rename
  my $move_code = &TWiki::Store::renameTopic( $srcWeb, $topic, $dstWeb, $topic, "relink" );
  return 1 if ( $move_code );
  return 0;
}

# Update topics' references
# TWiki initialization and tests must have been done before
sub updateReferences {
  my ( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, $type ) = @_;
  my @files = ();
  my @topics;
  # Get search regexps;
  my $theSearchVal = "($oldWeb\\.)?($oldTopic)(\[\^\\d\\w\\.\])";
  # Searching into a specific web
  if ( $type ) {
    push @files, "$oldWeb/*.txt";
    push @files, "$newWeb/*.txt" if ( $oldWeb ne $newWeb );
  } else {
    my @webs = &retrieveSubWebs();
    # Get associated files
    foreach my $current_web (@webs) {
      push @files, "$current_web/*.txt";
    }
  }
  @topics = &searchTopics( $theSearchVal, @files ) if ( @files && $#files >= 0 );
  # Update
  return &updateTopics( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, @topics ) if ( @topics && $#topics >= 0 );
}

# Retrieve all sub webs of a web
sub retrieveSubWebs {
  my ( $root ) = @_;
  my @webs = &TWiki::Store::getAllWebs( $root );
  # Delete Trash if configured for
  if ( ! $Service::updateTrash ) {
    my @nwebs = ();
    foreach my $web (@webs) {
      push @nwebs, $web if ( $web ne 'Trash' );
    }
    @webs = @nwebs;
  }
  my @results = @webs;
  # Look into subwebs
  foreach my $web (@webs) {
    if ( $Service::subwebs ) {
      push @results, &retrieveSubWebs( $web );
    }
  }
  return @results;
}

# Search pattern in given topics' filename
sub searchTopics {
  my ( $pattern, @topicList ) = @_;
  return () if ( ! @topicList );
  # Grep command
  my $cmd = "$TWiki::egrepCmd -l -- $TWiki::cmdQuote%TOKEN%$TWiki::cmdQuote %FILES%";
  my $acmd;
  my $tempVal;
  my $sDir = "$TWiki::dataDir";

  if( $pattern ) {
    # Do grep search
    chdir( "$sDir" );
    my $acmd = $cmd;
    $acmd =~ s/%TOKEN%/$pattern/o;
    $acmd =~ s/%FILES%/@topicList/;
    $acmd =~ /(.*)/;
    $acmd = "$1";
    $tempVal = `$acmd`;
    @topicList = split( /\n/, $tempVal );
   }
   my @tmpList = map { /(.*)\.txt$/; $_ = $1; } @topicList;
   @topicList = ();
   foreach( @tmpList ) {
     $tempVal = $_;
     if ( $tempVal =~ /(.*)[\/](.*)/ ) {
       # Add web to topic
       $tempVal = "$1.$2";
     }
     if( $tempVal ne '' ) {
       push @topicList, "$tempVal";
     }
   }
   return @topicList;
}

# Update topics' content and meta
sub updateTopics {
  my ( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, @topics ) = @_;
  my @updated_topics = ();
  return if ( ( $oldWeb eq $newWeb ) && ( $oldTopic eq $newTopic ) );
  my $theSearchValInWeb = "(\[\\s\\[\])($oldWeb\\.)?($oldTopic)(\[\^\\d\\w\\.\])";
  my $theSearchValOutWeb = "(\[\\s\\[\])($oldWeb\\.)($oldTopic)(\[\^\\d\\w\\.\])";
  my $theReplaceVal = "$newWeb.$newTopic";
  my $unlock = "on";
  my $dontNotify = "on";
  my $saveCmd = '';

  # Update each one
  foreach my $topic (@topics) {
    my ( $web, $topic ) = split /\./, $topic;
    # Initialize
    &Service::Connection::initialize( $login, $web, $topic );
    # Permissions check (change)
    if ( &Service::Topics::testAndGetTopic( $web, $topic, $login, 'change' ) ) {
      # Lock
      my $lock = &Service::Topics::lock( $key, $login, $web, $topic );
      if ( $lock ) {
        push @updated_topics, "$web.$topic";
        # Get meta/text
        my ( $meta, $text ) = &TWiki::Store::readTopic( $web, $topic );
        # Change parent if it is the one searched
        if( $meta->count( "TOPICPARENT" ) ) {
          my %parent = $meta->findOne( "TOPICPARENT" );
          # To compare exact values
          if ( ( $parent{"name"} eq "$oldTopic" && $oldWeb eq $web ) ||
                 $parent{"name"} eq "$oldWeb.$oldTopic" ) {
            $parent{"name"} = $theReplaceVal;
            $meta->put( "TOPICPARENT", %parent );
          }
        }
        # Space for manage links located in the beginning of the document
        $text = ' '.$text;
        # Pattern replacement
        if ( $oldWeb eq $web ) {
          # Replace occurrences of this type : (web.)?topic
          while ( $text =~ s/$theSearchValInWeb/$1$theReplaceVal$4/ ) {};
        } else {
          # Replace occurrences of this type : web.topic
          while ( $text =~ s/$theSearchValOutWeb/$1$theReplaceVal$4/ ) {};
        }
        # Deleting first space added
        $text =~ s/ //;
        # Save
        my $changeError = &TWiki::Store::saveTopic( $web, $topic, $text, $meta, $saveCmd, $unlock, $dontNotify );
        # Unlock
        &Service::Topics::lock( $key, $login, $web, $topic, 1 );
      }
    }
  }
  return @updated_topics;
}

# Remove operation
sub removeTopic {
  my ( $key, $web, $topic, $option, $trashName ) = @_;
  my $trashLock;
  my ( $lock, $lockUser );
  &Service::Trace::log( "Topic $web.$topic removing attempt by $key" );
  $option = 0 if ( ( $option eq 1 || $option eq 2 ) && ! $Service::allow_complete_remove );
  # Normalize web & topic name
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
  # Test parameters existence
  if ( ! &TWiki::Store::topicExists( $web, $topic ) ) { &Service::Trace::log( "Remove operation failed : topic $web.$topic doesn't exist" );return 3; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Remove operation failed : user $key not connected" );return 1; }
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Remove operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  # Manage new trash name
  $trashName = $topic if ( $trashName eq '' );
  # Test trash topic
  if ( ( $option ne 2 ) && &TWiki::Store::topicExists( 'Trash', $trashName ) ) {
    # Topic's new name exists in Trash
    if ( $option eq 1 ) {
      # Initialize
      &Service::Connection::initialize( $login, 'Trash', $trashName );
      # Check permissions
      if ( ! &Service::Topics::testAndGetTopic( 'Trash', $trashName, $login, 'rename' ) ) {
        &Service::Trace::log( "Remove operation failed : topic Trash.$trashName already exists, permissions to rename $trashName denied" );
        return 7;
      }
      # Check if topic is locked
      $trashLock = &Service::Topics::lock( $key, $login, 'Trash', $trashName );
      if ( ! $trashLock ) {
        &Service::Trace::log( "Remove operation failed : topic Trash.$trashName already exists and is locked" );
        return 7;
      };
      # Erase topic completely
      &TWiki::Store::erase( 'Trash', $trashName );
      # Unlock
      &Service::Topics::lock( $key, $login, 'Trash', $trashName, 1 );
      return 0 if ( $web eq 'Trash' );
    }
    else {
      # Manage option 0 - generate a non existing trash name
      if ( $option eq 0 && $Service::allow_generate_trashID ) {
        my $id = 0;
        while ( &TWiki::Store::topicExists( 'Trash', $trashName."Trash$id" ) ) {
          $id++;
        }
        $trashName .= "Trash$id";
      } else {
        &Service::Trace::log( "Remove operation failed : topic Trash.$trashName already exists" );
        return 7;
      }
    }
  }
  # Initialize topic
  &Service::Connection::initialize( $login, $web, $topic );
  # Check permissions
  if ( ! &Service::Topics::testAndGetTopic( $web, $topic, $login, 'rename' ) ) {
    &Service::Trace::log( "Remove operation failed : permissions denied" );
    return 4;
  }
  if ( $option eq 2 ) {
    # Completely erase topic
    # Check if topic is locked
    ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $web, $topic );
    if ( ! $lock ) {
      &Service::Trace::log( "Remove operation failed : unable to put lock on topic $web.$topic, already put by $lockUser" );
      return ( 5, $lockUser );
    }
    # Erase topic completely
    &TWiki::Store::erase( $web, $topic );
    # Unlock
    &Service::Topics::lock( $key, $login, $web, $topic, 1 );
    &Service::Trace::log( "Remove operation succeded" );
    return 0;
  }
  # Test if target name is a WikiWord
  if ( ! &TWiki::isWikiName( $trashName ) ) {
    &Service::Trace::log( "Remove operation failed : $trashName isn't a WikiWord" );
    return 6;
  }
  # Check if topic is locked
  ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $web, $topic );
  if ( ! $lock ) {
    &Service::Trace::log( "Remove operation failed : unable to put lock on topic $web.$topic, already put by $lockUser" );
    return ( 5, $lockUser );
  }
  my $rename_code = &TWiki::Store::renameTopic( $web, $topic, 'Trash', $trashName, "relink" );
  if ( $rename_code ) { &Service::Trace::log( "Remove error : $rename_code" );return ( 8, $rename_code ); }
  &Service::Trace::log( "Remove operation succeded" );
  return 0;
}

# Merge operation
sub mergeTopics {
  my ( $key, $webTarget, $topicTarget, $webFrom, $topicFrom, $attachments, $identify, $removeOption, $dontNotify ) = @_;
  my $saveCmd = '';
  my $unlock = "on";
  &Service::Trace::log( "Topics $webTarget.$topicTarget & $webFrom.$topicFrom merging attempt by $key" );
  # Normalize web & topic name
  ( $webTarget, $topicTarget ) = &TWiki::Store::normalizeWebTopicName( $webTarget, $topicTarget );
  ( $webFrom, $topicFrom ) = &TWiki::Store::normalizeWebTopicName( $webFrom, $topicFrom );
  # Tests topics
  $topicFrom = $TWiki::mainTopicname if ( $topicFrom eq '' );
  $topicTarget = $TWiki::mainTopicname if ( $topicTarget eq '' );
  # Test parameters existence
  if ( ! &TWiki::Store::topicExists( $webTarget, $topicTarget ) ) { &Service::Trace::log( "Merge operation failed : topic $webTarget.$topicTarget doesn't exist" );return 3; }
  if ( ! &TWiki::Store::topicExists( $webFrom, $topicFrom ) ) { &Service::Trace::log( "Merge operation failed : topic $webFrom.$topicFrom doesn't exist" );return 4; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Merge operation failed : user $key not connected" );return 1; }
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Merge operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  if (( $webTarget eq $webFrom ) && ( $topicTarget eq $topicFrom )) { &Service::Trace::log( "Merge operation failed : topics are the same" );return 5; }
  if ( ! &Service::Topics::testAndGetTopic( $webFrom, $topicFrom, $login, 'view' ) ) {
    &Service::Trace::log( "Merge operation failed : permissions to view $webFrom.$topicFrom denied" );
    return 6;
  }
  # Retrieve Auxiliary Topic's content
  my ( $metaFrom, $textFrom ) = &TWiki::Store::readTopic( $webFrom, $topicFrom );
  # Retrieve Target's content
  my ( $metaTarget, $textTarget ) = &TWiki::Store::readTopic( $webTarget, $topicTarget );
  # Identification if wanted
  if ( $identify ) {
     my $header = '---+Merge Result';
     my $newText = "$header\n<verbatim>\n";
     $newText = &writeDetailedMergedTopic($webTarget, $topicTarget, $header, $textTarget, $newText);
     $newText .= "----\n";
     $newText = &writeDetailedMergedTopic($webFrom, $topicFrom, $header, $textFrom, $newText);
     $newText .= "</verbatim>";
     $textTarget = $newText;
  } else {
     # Merge simply with concatenation
     $textTarget .= $textFrom;
  }
  # Initialize topic
  &Service::Connection::initialize( $login, $webTarget, $topicTarget );
  # Check permissions
  if ( ! &Service::Topics::testAndGetTopic( $webTarget, $topicTarget, $login, 'change' ) ) { 
    &Service::Trace::log( "Merge operation failed : permissions to change $webTarget.$topicTarget denied" );
    return 6;
  }
  # Check if topic is locked
  my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $webTarget, $topicTarget );
  if ( ! $lock ) {
    &Service::Trace::log( "Merge operation failed : unable to put lock on topic $webTarget.$topicTarget, already put by $lockUser" );
    return ( 7, $lockUser );
  }
  # Copy attachments
  $metaTarget = &copyAttachments( $metaFrom, $metaTarget, $webFrom, $topicFrom, $webTarget, $topicTarget ) if ( $attachments );
  # Saving
  my $change_code = &TWiki::Store::saveTopic( $webTarget, $topicTarget, $textTarget, $metaTarget, $saveCmd, $unlock, $dontNotify );
  if( $change_code ) { &Service::Trace::log( "Save error : $change_code" );return( 8, $change_code ); }
  # Delete auxiliary topic
  my $remove_code;
  $remove_code = &removeTopic($key, $webFrom, $topicFrom, $removeOption) if ( $removeOption ne -1);
  if ( $remove_code ) { &Service::Trace::log( "Remove error : $remove_code" );return( 9, $remove_code ); }
  &Service::Trace::log( "Merge operation succeded" );
  return 0;
}

# Write trace of merge
sub writeDetailedMergedTopic {
  my ( $web, $topic, $header, $source, $newText ) = @_;
  my @lines = split/\n/, $source;
  # Range of text covered
  my $i = 0;
  my $n = $#lines + 1;
  # We deal with an already merged page with indications ?
  my $already_merged = 0;
  if ( $lines[0] eq $header ) {
    $already_merged = 1;
    $i = 2;
    $n--;
  }
  # Write lines
  while( $i < $n ) {
    if ( $already_merged ) {
      $newText .= "$lines[$i]\n";
    } else {
      $newText .= "$web.$topic > $lines[$i]\n";
    }
    $i++;
  }
  return $newText;
}

# Copy operation
sub copyTopic {
  my ( $key, $srcWeb, $topic, $dstWeb, $newName, $parent, $attachments ) = @_;
  my $saveCmd = '';
  my $unlock = "on";
  my $dontNotify = "on";
  &Service::Trace::log( "Topic $srcWeb.$topic copying attempt by $key" );
  # Test empty parameters
  $parent = $TWiki::mainTopicname if ( $parent eq '' );
  # Normalize webs & topics name
  ( $srcWeb, $topic ) = &TWiki::Store::normalizeWebTopicName( $srcWeb, $topic );
  ( $dstWeb, $newName ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $newName );
  ( $dstWeb, $parent ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $parent );
  # Test webs and topics existence
  if ( ! &TWiki::Store::topicExists( $srcWeb, $topic ) ) { &Service::Trace::log( "Copy operation failed : topic $srcWeb.$topic doesn't exist" );return 3; }
  if ( &TWiki::Store::topicExists( $dstWeb, $newName ) ) { &Service::Trace::log( "Copy operation failed : topic $dstWeb.$newName already exists" );return 4; }
  if ( ! &TWiki::Store::topicExists( $dstWeb, $parent ) ) { &Service::Trace::log( "Copy operation failed : topic $dstWeb.$parent doesn't exist" );return 5; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Copy operation failed : user $key not connected" );return 1; }
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Copy operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  # Initialize
  &Service::Connection::initialize( $login, $dstWeb, $newName );
  # Test if target name is a WikiWord
  if ( ! &TWiki::isWikiName( $newName ) ) { &Service::Trace::log( "Copy operation failed : $newName isn't a WikiWord" );return 6; }
  # Check permissions
  if ( ! &Service::Topics::testAndGetTopic( $srcWeb, $topic, $login, 'view' ) ) { 
    &Service::Trace::log( "Copy operation failed : permissions to change $srcWeb.$topic denied" );
    return 7;
  }
  # Check if topic is locked
  my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $dstWeb, $newName );
  if ( ! $lock ) {
    &Service::Trace::log( "Copy operation failed : unable to put lock on topic $dstWeb.$newName, already put by $lockUser" );
    return ( 8, $lockUser );
  }
  # Read source topic
  my ( $srcMeta, $srcText ) = &TWiki::Store::readTopic( $srcWeb, $topic );
  # Read template for new meta
  my ( $newMeta, $newText ) = &TWiki::Store::readTemplateTopic( "WebTopicEditTemplate" );
  # Change parent on meta
  $newMeta->put( "TOPICPARENT", ( "name" => "$dstWeb.$parent" ) );
  # Copy attachments
  $newMeta = &copyAttachments( $srcMeta, $newMeta, $srcWeb, $topic, $dstWeb, $newName )  if ( $attachments );
  # Save
  my $change_code = &TWiki::Store::saveTopic( $dstWeb, $newName, $srcText, $newMeta, $saveCmd, $unlock, $dontNotify );
  if ( $change_code ) { &Service::Trace::log( "Copy error : $change_code" );return ( 9, $change_code ); }
  &Service::Trace::log( "Copy operation succeded" );
  return 0;
}

# Copy attachment from topic to another
sub copyAttachments {
  my ( $meta1, $meta2, $oldWeb, $oldTopic, $newWeb, $newTopic ) = @_;
  # Retrieve source attachments
  my @attachs = $meta1->find( "FILEATTACHMENT" );
  foreach my $attach (@attachs) {
    # Retrieve properties
    my $oldName     = $attach->{"name"};
    my $name        = $attach->{"name"};
    my $attrVersion = $attach->{"version"};
    my $attrPath    = $attach->{"path"};
    my $attrSize    = $attach->{"size"};
    my $attrDate    = $attach->{"date"};
    my $attrUser    = $attach->{"user"};
    my $attrComment = $attach->{"comment"};
    my $attrAttr    = $attach->{"attr"};
    # Name tests and modifications
    if ( &Service::Topics::isAttachName( $name, $meta2 ) ) {
      my $tempName = $name;
      my $id = 1;
      while ( &Service::Topics::isAttachName( $tempName, $meta2 ) ) {
        if ( $name =~ m/(.+)\.(.+)/ ) {
          $tempName = $1."_".$id.".$2";
        } else {
          $tempName = $name."_$id";
        }
        $id = $id + 1;
      }
      $name = $tempName;
    }
    # Pub directory actions
    my ( $copy_code, $newAttach ) = &copyAttachmentFile( $oldWeb, $oldTopic, $newWeb, $newTopic, $oldName, $name );
    # Try to delete if errors when creation
    $newAttach->_delete() if ( $copy_code );
    # Meta actions
    &TWiki::Attach::updateAttachment(
                $attrVersion, $name, $attrPath, $attrSize,
                $attrDate, $attrUser, $attrComment, $attrAttr, $meta2 ) if ( ! $copy_code );
  }
  return $meta2;
}

# Copy an attachment file
# Tests must have been done before
# Return error code and new attachment
sub copyAttachmentFile {
  my ( $oldWeb, $oldTopic, $newWeb, $newTopic, $oldName, $name, $doMove ) = @_;
  my $topicHandler = &TWiki::Store::_getTopicHandler( $oldWeb, $oldTopic, $oldName );
  my $new = TWiki::Store::RcsFile->new( $newWeb, $newTopic, $name,
        ( pubDir => $TWiki::pubDir ) );
  my $oldAttachment = $topicHandler->{file};
  my $newAttachment = $new->{file};
  # Before save, create directories if they don't exist
  my $tempPath = $new->_makePubWebDir();
  unless( -e $tempPath ) {
    umask( 0 );
    mkdir( $tempPath, 0775 );
  }
  $tempPath = $new->_makeFileDir( 1 );
  unless( -e $tempPath ) {
    umask( 0 );
    mkdir( $tempPath, 0775 );
  }
  # Copy attachment
  if ( $doMove ) {
    if( ! move( $oldAttachment, $newAttachment ) ) {
        return ( 1, $new );
    }
  } else {
    if( ! copy( $oldAttachment, $newAttachment ) ) {
        return ( 1, $new );
    }
  }
  # Make sure rcs directory exists
  my $newRcsDir = $new->_makeFileDir( 1, ",v" );
  if ( ! -e $newRcsDir ) {
     umask( 0 );
     mkdir( $newRcsDir, $topicHandler->{dirPermission} );
  }
  # Copy attachment history
  my $oldAttachmentRcs = $topicHandler->{rcsFile};
  my $newAttachmentRcs = $new->{rcsFile};
  if( -e $oldAttachmentRcs ) {
    if ( $doMove ) {
      if( ! move( $oldAttachmentRcs, $newAttachmentRcs ) ) {

        return ( 2, $new );
      }
    } else {
      if( ! copy( $oldAttachmentRcs, $newAttachmentRcs ) ) {
        return ( 2, $new );
      }
    }
  }
  return ( 0, $new );
}

1;