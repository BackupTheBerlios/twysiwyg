package Service::Refactoring;

# Refactoring Module
# Author : Romain Raugi

use strict;
use File::Copy;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

# Rename topic operation
sub renameTopic {
  my ( $key, $web, $topic, $name, $doUpdate, $doBreakLock ) = @_;
  &Service::Trace::log( "Topic $web.$topic renaming attempt by $key" );
  # Normalize web & topic name
  $topic = $TWiki::mainTopicname if ( $topic eq '' );
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
  # Test parameters existence
  if ( ! &TWiki::Store::topicExists( $web, $topic ) ) { &Service::Trace::log( "Rename operation failed : topic $web.$topic doesn't exist" );return 3; }
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
  if ( ! $login ) { &Service::Trace::log( "Rename operation failed : user $key not connected" );return 1; }
  # Check administrative lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Rename operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin( $lockedKey ) );
  }
  # Initialize
  &Service::Connection::initialize( $login, $web, $topic );
  # Test if name is a WikiWord
  if ( ! &TWiki::isWikiName( $name ) ) { &Service::Trace::log( "Rename operation failed : new name $name isn't a WikiWord" );return 5; }
  # Test destination topic inexistence
  if ( &TWiki::Store::topicExists( $web, $name ) ) { &Service::Trace::log( "Rename operation failed : topic $web.$name already exists" );return 4; }
  # Check if topic is locked
  if ( ! $doBreakLock ) {
    my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $web, $topic );
    if ( ! $lock ) {
      &Service::Trace::log( "Rename operation failed : unable to put lock on topic $web.$topic, already put by $lockUser" );
      return ( 6, $lockUser );
    }
  }
  # Rename
  my $renameCode = &TWiki::Store::renameTopic( $web, $topic, $web, $name, "relink" );
  if ( $renameCode ) { &Service::Trace::log( "Rename error : $renameCode" );return ( 7, $renameCode ); }
  my @updatedTopics = ();
  # Update links that refers to
  @updatedTopics = &_updateReferences( $key, $login, $web, $topic, $web, $name, 1 ) if ( $doUpdate );
  my $updated = join( @updatedTopics, "," );
  &Service::Trace::log( "Rename operation succeded, topics $updated updated" );
  return 0;
}

# Move operation
sub moveTopic {
  my ( $key, $srcWeb, $topic, $dstWeb, $parent, $doUpdate, $doBreakLock ) = @_;
  &Service::Trace::log( "Topic $srcWeb.$topic moving attempt by $key" );
  # Test empty parameters
  $topic = $TWiki::mainTopicname if ( $topic eq '' );
  $parent = $TWiki::mainTopicname if ( $parent eq '' );
  # Normalize webs & topics name
  ( $srcWeb, $topic ) = &TWiki::Store::normalizeWebTopicName( $srcWeb, $topic );
  ( $dstWeb, $parent ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $parent );
  # Test webs and topics existence
  if ( ! &TWiki::Store::topicExists( $srcWeb, $topic ) ) { &Service::Trace::log( "Move operation failed : topic $srcWeb.$topic doesn't exist" );return 3; }
  if ( ! &TWiki::Store::topicExists( $dstWeb, $parent ) ) { &Service::Trace::log( "Move operation failed : topic $dstWeb.$parent doesn't exist" );return 4; }
  # Retrieve login
  my $login = &Service::Connection::getLogin( $key );
  if ( ! $login ) { &Service::Trace::log( "Move operation failed : user $key not connected" );return 1; }
  # Check administrative lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Move operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin( $lockedKey ) );
  }
  # Initialize
  &Service::Connection::initialize( $login, $srcWeb, $topic );
  # Check if topic is locked
  if ( ! $doBreakLock ) {
    my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $srcWeb, $topic );
    if ( ! $lock ) {
      &Service::Trace::log( "Move operation failed : unable to put lock on topic $srcWeb.$topic, already put by $lockUser" );
      return ( 5, $lockUser );
    }
  }
  # Moving
  if ( $srcWeb ne $dstWeb ) {
    # Error case : topic existence in destination
    if ( &TWiki::Store::topicExists( $dstWeb, $topic ) ) { &Service::Trace::log( "Move operation failed : topic $dstWeb.$topic already exists" );return 6; }
    # Move topic
    my $moveCode = &TWiki::Store::renameTopic( $srcWeb, $topic, $dstWeb, $topic, "relink" );
    if ( $moveCode ) { &Service::Trace::log( "Move error : $moveCode" );return ( 7, $moveCode ); }
  }
  # Change parent
  my $changeCode = &_changeParent( $dstWeb, $topic, $parent );
  if ( $changeCode ) { &Service::Trace::log( "Error during parent change : $changeCode" );return ( 8, $changeCode ); }
  # Update links that refers to
  # References need to be updated only if topic has been moved in another web
  my @updatedTopics = ();
  @updatedTopics = &_updateReferences( $key, $login, $srcWeb, $topic, $dstWeb, $topic, 1 ) if ( ( $srcWeb ne $dstWeb ) && $doUpdate );
  my $updated = join( @updatedTopics, "," );
  &Service::Trace::log( "Move operation succeded, topics $updated updated" );
  return 0;
}

sub _changeParent {
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

# Update topics' references
# TWiki initialization and tests must have been done before
sub _updateReferences {
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
    my @webs = &TWiki::Store::getAllWebs();
    # Get associated files
    foreach my $current_web (@webs) {
      push @files, "$current_web/*.txt";
    }
  }
  @topics = &_searchTopics( $theSearchVal, @files ) if ( @files && $#files >= 0 );
  # Update
  return &_updateTopics( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, @topics ) if ( @topics && $#topics >= 0 );
}

# Search pattern in given topics' filename
sub _searchTopics {
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
sub _updateTopics {
  my ( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, @topics ) = @_;
  my @updatedTopics = ();
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
    push @updatedTopics, "$web.$topic";
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
  }
  return @updatedTopics;
}

# Remove operation
sub removeTopic {
  my ( $key, $web, $topic, $trashName, $doBreakLock ) = @_;
  my $trashLock;
  my ( $lock, $lockUser );
  &Service::Trace::log( "Topic $web.$topic removing attempt by $key" );
  # Normalize web & topic name
  $topic = $TWiki::mainTopicname if ( $topic eq '' );
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
  # Test parameters existence
  if ( ! &TWiki::Store::topicExists( $web, $topic ) ) { &Service::Trace::log( "Remove operation failed : topic $web.$topic doesn't exist" );return 3; }
  # Retrieve login
  my $login = &Service::Connection::getLogin( $key );
  if ( ! $login ) { &Service::Trace::log( "Remove operation failed : user $key not connected" );return 1; }
  # Check administrative lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Remove operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin( $lockedKey ) );
  }
  # Manage new trash name
  $trashName = $topic if ( $trashName eq '' );
  # Test trash topic
  if ( &TWiki::Store::topicExists( 'Trash', $trashName ) ) {
    # Generate a non existing trash name
    my $id = 0;
    while ( &TWiki::Store::topicExists( 'Trash', $trashName."Trash$id" ) ) {
      $id++;
    }
    $trashName .= "Trash$id";
  }
  # Initialize topic
  &Service::Connection::initialize( $login, $web, $topic );
  # Test if target name is a WikiWord
  if ( ! &TWiki::isWikiName( $trashName ) ) {
    &Service::Trace::log( "Remove operation failed : $trashName isn't a WikiWord" );
    return 5;
  }
  # Check if topic is locked
  if ( ! $doBreakLock ) {
    ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $web, $topic );
    if ( ! $lock ) {
      &Service::Trace::log( "Remove operation failed : unable to put lock on topic $web.$topic, already put by $lockUser" );
      return ( 4, $lockUser );
    }
  }
  my $renameCode = &TWiki::Store::renameTopic( $web, $topic, 'Trash', $trashName, "relink" );
  if ( $renameCode ) { &Service::Trace::log( "Remove error : $renameCode" );return ( 6, $renameCode ); }
  &Service::Trace::log( "Remove operation succeded" );
  return 0;
}

# Merge operation
sub mergeTopics {
  my ( $key, $webTarget, $topicTarget, $webFrom, $topicFrom, $doAttachments, $doBreakLock, $doRemove, $dontNotify ) = @_;
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
  # Check administrative lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
  if ( ( ! $checkCode ) || ( ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) ) {
    &Service::Trace::log( "Merge operation failed : administrative lock control failed, not put or put by another user ($lockedKey)" );
    return ( 2, &Service::Connection::getLogin($lockedKey) );
  }
  if (( $webTarget eq $webFrom ) && ( $topicTarget eq $topicFrom )) { &Service::Trace::log( "Merge operation failed : topics are the same" );return 5; }
  # Initialize topic
  &Service::Connection::initialize( $login, $webTarget, $topicTarget );  
  # Retrieve Auxiliary Topic's content
  my ( $metaFrom, $textFrom ) = &TWiki::Store::readTopic( $webFrom, $topicFrom );
  # Retrieve Target's content
  my ( $metaTarget, $textTarget ) = &TWiki::Store::readTopic( $webTarget, $topicTarget );
  # Concat
  $textTarget .= $textFrom;
  # Check if topic is locked
  if ( ! $doBreakLock ) {
    my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $webTarget, $topicTarget );
    if ( ! $lock ) {
      &Service::Trace::log( "Merge operation failed : unable to put lock on topic $webTarget.$topicTarget, already put by $lockUser" );
      return ( 6, $lockUser );
    }
  }
  # Copy attachments
  my $attachmentsCode = 0;
  ( $attachmentsCode, $metaTarget ) = &_copyAttachments( $metaFrom, $metaTarget, $webFrom, $topicFrom, $webTarget, $topicTarget ) if ( $doAttachments );
  if ( $attachmentsCode ) {
    &Service::Trace::log( "Merge operation : attachments copy succeeded" );
  } else {
    &Service::Trace::log( "Merge operation : attachments copy error : $attachmentsCode" );
  }
  # Saving
  my $changeCode = &TWiki::Store::saveTopic( $webTarget, $topicTarget, $textTarget, $metaTarget, $saveCmd, $unlock, $dontNotify );
  if( $changeCode ) { &Service::Trace::log( "Save error : $changeCode" );return( 7, $changeCode ); }
  # Delete auxiliary topic
  my $removeCode;
  $removeCode = &removeTopic( $key, $webFrom, $topicFrom ) if ( $doRemove );
  if ( $removeCode ) { &Service::Trace::log( "Remove error : $removeCode" );return( 8, $removeCode ); }
  &Service::Trace::log( "Merge operation done" );
  return ( 9, $attachmentsCode ) if ( $attachmentsCode );
  return 0;
}

# Copy operation
sub copyTopic {
  my ( $key, $srcWeb, $topic, $dstWeb, $newName, $parent, $doAttachments, $doBreakLock ) = @_;
  my $saveCmd = '';
  my $unlock = "on";
  my $dontNotify = "on";
  &Service::Trace::log( "Topic $srcWeb.$topic copying attempt by $key" );
  # Test empty parameters
  $newName = $topic if ( $newName eq '' );
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
  # Check administrative lock
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
  # Check if topic is locked
  if ( ! $doBreakLock ) {
    my ( $lock, $lockUser ) = &Service::Topics::lock( $key, $login, $dstWeb, $newName );
    if ( ! $lock ) {
      &Service::Trace::log( "Copy operation failed : unable to put lock on topic $dstWeb.$newName, already put by $lockUser" );
      return ( 7, $lockUser );
    }
  }
  # Read source topic
  my ( $srcMeta, $srcText ) = &TWiki::Store::readTopic( $srcWeb, $topic );
  # Read template for new meta
  my ( $newMeta, $newText ) = &TWiki::Store::readTemplateTopic( "WebTopicEditTemplate" );
  # Change parent on meta
  $newMeta->put( "TOPICPARENT", ( "name" => "$dstWeb.$parent" ) );
  # Copy attachments
  my $attachmentsCode = 0;
  ( $attachmentsCode, $newMeta ) = &_copyAttachments( $srcMeta, $newMeta, $srcWeb, $topic, $dstWeb, $newName )  if ( $doAttachments );
  if ( $attachmentsCode ) {
    &Service::Trace::log( "Copy operation : attachments copy succeeded" );
  } else {
    &Service::Trace::log( "Copy operation : attachments copy error : $attachmentsCode" );
  }
  # Save
  my $changeCode = &TWiki::Store::saveTopic( $dstWeb, $newName, $srcText, $newMeta, $saveCmd, $unlock, $dontNotify );
  if ( $changeCode ) { &Service::Trace::log( "Copy error : $changeCode" );return ( 8, $changeCode ); }
  &Service::Trace::log( "Copy operation done" );
  return ( 9, $attachmentsCode ) if ( $attachmentsCode );
  return 0;
}

# Copy attachment from topic to another
sub _copyAttachments {
  my ( $meta1, $meta2, $oldWeb, $oldTopic, $newWeb, $newTopic ) = @_;
  # Retrieve source attachments
  my @attachs = $meta1->find( "FILEATTACHMENT" );
  my ( $copyCode, $newAttach );
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
    if ( &_isAttachName( $name, $meta2 ) ) {
      my $tempName = $name;
      my $id = 1;
      while ( &_isAttachName( $tempName, $meta2 ) ) {
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
    ( $copyCode, $newAttach ) = &_copyAttachmentFile( $oldWeb, $oldTopic, $newWeb, $newTopic, $oldName, $name );
    # Try to delete if errors when creation
    $newAttach->_delete() if ( $copyCode );
    # Meta actions
    &TWiki::Attach::updateAttachment(
                $attrVersion, $name, $attrPath, $attrSize,
                $attrDate, $attrUser, $attrComment, $attrAttr, $meta2 ) if ( ! $copyCode );
  }
  return ( $copyCode, $meta2 );
}

# Copy an attachment file
# Tests must have been done before
# Return error code and new attachment
sub _copyAttachmentFile {
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

# Test if an attach name is in meta information
sub _isAttachName {
  my ( $name, $meta ) = @_;
  my @attachs = $meta->find( "FILEATTACHMENT" );
  my $i = 0;
  my $n = $#attachs + 1;
  my $found = 0;
  # Look for attach name
  while ( $i < $n && ! $found ) {
    $found = 1 if ( $attachs[$i]->{"name"} eq $name );
    $i++;
  }
  return $found;
}

1;