package Service::Refactoring;

# Refactoring Module
# Author : Romain Raugi, based on Peter Thoeny's works for TWiki

use strict;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

# Web Service
sub renameTopic {
  my $object = shift;
  my ( $key, $web, $topic, $name, $update ) = @_;
&Service::Trace::TRACE("RenameTopic Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("New Name : $name");
&Service::Trace::TRACE("Update : $update");
  # Normalize web & topic name
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
&Service::Trace::TRACE("Normalized Web : $web");
&Service::Trace::TRACE("Normalized Topic : $topic");
  # Test parameters existence
  return 3 if ( ! &TWiki::Store::topicExists( $web, $topic ) );
  # Test subweb authorization
  return 10 if ( ( $web =~ m/\// ) && ( ! $Service::subwebs ) );
&Service::Trace::TRACE("Topics and Webs OK");
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
&Service::Trace::TRACE("Login $login exists");
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
&Service::Trace::TRACE("Admin lock CheckCode : $checkCode");
&Service::Trace::TRACE("Admin lock : LockedKey ne Key : ".($lockedKey ne $key));
&Service::Trace::TRACE("Admin lock : Dates : ".(( $date - $lockedTime ) < $Service::timeout));
  return 2 if ( ( $Service::admin_lock && ! $checkCode ) || ( $Service::admin_lock && $checkCode && ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) );
&Service::Trace::TRACE("Admin lock : $checkCode, $lockedKey, $lockedTime");
  # Initialize
  &Service::Connection::initialize( $login, $web, $topic );
  # Test if name is a WikiWord
  return 5 if ( ! &TWiki::isWikiName( $name ) );
 &Service::Trace::TRACE("New Name $name is WikiWord");
  # Test destination topic inexistence
  return 4 if ( &TWiki::Store::topicExists( $web, $name ) );
 &Service::Trace::TRACE("Topic $web.$name doesn't exist : OK");
  # Check permissions
  return 6 if ( ! &Service::Topics::hasPermissions( $web, $topic, $login, 'rename' ) );
&Service::Trace::TRACE("$login has rename/change permissions");
  # Check if topic is locked
  my $lock = &Service::Topics::lock( $key, $login, $web, $topic, 1 );
  return 7 if ( ! $lock );
  # Rename
  my $rename_code = &TWiki::Store::renameTopic( $web, $topic, $web, $name, "relink" );
&Service::Trace::TRACE("Rename Error : $rename_code");
  return 8 if ( $rename_code );
  my @updated_topics = ();
  my $event;
  # Update links that refers to
  if ( $update eq 1 ) {
    @updated_topics = &updateReferences( $key, $login, $web, $topic, $web, $name );
  } elsif ( $update eq 2 ) {
    @updated_topics = &updateReferences( $key, $login, $web, $topic, $web, $name, 1 );
  }
  if ( $Service::notifications ) {
    foreach my $updated (@updated_topics) {
      # Notify event
      my ( $topic_web, $topic_name ) = split/\./, $updated;
      $event = Service::Notification::TopicEvent->new( "$topic_web", "$topic_name", "links" );
      &Service::Notification::send( $key, 4, "$login", "$login updated links of $topic_web.$topic_name", $event );
    }
  }
  # Notify event
  if ( $Service::notifications ) {
    $event = Service::Notification::RefactoringEvent->new( "$web", "$topic", "", "$web", "$name", "", "rename" );
    &Service::Notification::send( $key, 3, "$login", "$login renamed $web.$topic to $web.$name", $event );
  }
  return 0;
}

# Web Service
sub moveTopic {
  my $object = shift;
  my ( $key, $srcWeb, $topic, $dstWeb, $parent, $update ) = @_;
&Service::Trace::TRACE("MoveTopic Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("srcWeb : $srcWeb");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("dstWeb : $dstWeb");
&Service::Trace::TRACE("Parent : $parent");
&Service::Trace::TRACE("Update : $update");
  # Test empty parameters
  $parent = $TWiki::mainTopicname if ( $parent eq '' );
  # Normalize webs & topics name
  ( $srcWeb, $topic ) = &TWiki::Store::normalizeWebTopicName( $srcWeb, $topic );
  ( $dstWeb, $parent ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $parent );
&Service::Trace::TRACE("Normalized srcWeb : $srcWeb");
&Service::Trace::TRACE("Normalized Topic : $topic");
&Service::Trace::TRACE("Normalized dstWeb : $dstWeb");
&Service::Trace::TRACE("Normalized Parent : $parent");
  # Test webs and topics existence
  return 3 if ( ! &TWiki::Store::topicExists( $srcWeb, $topic ) );
&Service::Trace::TRACE("Source topic and web OK");
  return 4 if ( ! &TWiki::Store::topicExists( $dstWeb, $parent ) );
  # Test subweb authorization
  return 10 if ( ( ( $srcWeb =~ m/\// ) || ( $dstWeb =~ m/\// ) ) && ( ! $Service::subwebs ) );
&Service::Trace::TRACE("Destination topic and web OK");
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
&Service::Trace::TRACE("Login $login exists");
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
&Service::Trace::TRACE("Admin lock CheckCode : $checkCode");
&Service::Trace::TRACE("Admin lock : LockedKey ne Key : ".($lockedKey ne $key));
&Service::Trace::TRACE("Admin lock : Dates : ".(( $date - $lockedTime ) < $Service::timeout));
  return 2 if ( ( $Service::admin_lock && ! $checkCode ) || ( $Service::admin_lock && $checkCode && ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) );
&Service::Trace::TRACE("Admin lock : $checkCode, $lockedKey, $lockedTime");
  # Initialize
  &Service::Connection::initialize( $login, $srcWeb, $topic );
  # Check permissions
  my $permission = "change";
  $permission = "rename" if ( $srcWeb ne $dstWeb );
  return 5 if ( ! &Service::Topics::hasPermissions( $srcWeb, $topic, $login, $permission ) );
&Service::Trace::TRACE("$login has $permission permissions");
  # Check if topic is locked
  my $lock = &Service::Topics::lock( $key, $login, $srcWeb, $topic, 1 );
  return 6 if ( ! $lock );
&Service::Trace::TRACE("Locking OK");
  # Moving
  if ( $srcWeb ne $dstWeb ) {
&Service::Trace::TRACE("Moving topic in another web");
    # Error case : topic existence in destination
    return 7 if ( &TWiki::Store::topicExists( $dstWeb, $topic ) );
&Service::Trace::TRACE("Destination OK");
    # Move topic
    my $move_code = &moveTopicOutsideWeb( $srcWeb, $topic, $dstWeb );
&Service::Trace::TRACE("Move Code : $move_code");
    return 8 if ( $move_code );
  }
  # Change parent
  my $change_code = &changeParent( $dstWeb, $topic, $parent );
&Service::Trace::TRACE("Change Parent Code : $change_code");
  return 9 if ( $change_code );
  my $event;
  # Update links that refers to
  # References need to be updated only if topic has been moved in another web
  if ( $srcWeb ne $dstWeb ) {
    my @updated_topics = ();
    if ( $update eq 1 ) {
      @updated_topics = &updateReferences( $key, $login, $srcWeb, $topic, $dstWeb, $topic );
    } elsif ( $update eq 2 ) {
      @updated_topics = &updateReferences( $key, $login, $srcWeb, $topic, $dstWeb, $topic, 1 );
    }
    if ( $Service::notifications ) {
      foreach my $updated (@updated_topics) {
        # Notify event
        my ( $topic_web, $topic_name ) = split/\./, $updated;
        $event = Service::Notification::TopicEvent->new( "$topic_web", "$topic_name", "links" );
        &Service::Notification::send( $key, 4, "$login", "$login updated links of $topic_web.$topic_name", $event );
      }
    }
  }
  # Notify event
  if ( $Service::notifications ) {
    $event = Service::Notification::RefactoringEvent->new( "$srcWeb", "$topic", "", "$dstWeb", "$topic", "$parent", "move" );
    &Service::Notification::send( $key, 3, "$login", "$login moved $topic from $srcWeb to $dstWeb and changed parent to $parent", $event );
  }
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
&Service::Trace::TRACE("Change Parent Code : $change_code");
  return 1 if( $change_code );
  return 0;
}

sub moveTopicOutsideWeb {
  my ( $srcWeb, $topic, $dstWeb ) = @_;
  # Rename
  my $move_code = &TWiki::Store::renameTopic( $srcWeb, $topic, $dstWeb, $topic, "relink" );
&Service::Trace::TRACE("Move Code : $move_code");
  return 1 if ( $move_code );
  return 0;
}

# Update topics' references
# TWiki initialization and tests must have been done before
sub updateReferences {
  my ( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, $type ) = @_;
  my @files = ();
  my @topics;
&Service::Trace::TRACE("UpdateReferences Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Login : $login");
&Service::Trace::TRACE("OldWeb : $oldWeb");
&Service::Trace::TRACE("OldTopic : $oldTopic");
&Service::Trace::TRACE("NewWeb : $newWeb");
&Service::Trace::TRACE("NewTopic : $newTopic");
&Service::Trace::TRACE("Type : $type");
  # Get search regexps;
  my $theSearchVal = "($oldWeb\\.)?($oldTopic)(\[\^\\d\\w\\.\])";
&Service::Trace::TRACE("TheSearchVal : $theSearchVal");
  # Searching into a specific web
  if ( $type ) {
&Service::Trace::TRACE("Searching into a specific web");
    push @files, "$oldWeb/*.txt";
    push @files, "$newWeb/*.txt" if ( $oldWeb ne $newWeb );
  } else {
&Service::Trace::TRACE("Searching in all webs");
    my @webs = &retrieveSubWebs();
&Service::Trace::TRACE("Webs : @webs");
    # Get associated files
    foreach my $current_web (@webs) {
      push @files, "$current_web/*.txt";
    }
  }
&Service::Trace::TRACE("Searching into these files : @files");
  @topics = &searchTopics( $theSearchVal, @files ) if ( @files && $#files >= 0 );
&Service::Trace::TRACE("Topics : @topics");
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
&Service::Trace::TRACE("SearchTopics Procedure");
&Service::Trace::TRACE("Pattern : $pattern");
&Service::Trace::TRACE("TopicList : @topicList");
  return () if ( ! @topicList );
  # Grep command
  my $cmd = "$TWiki::egrepCmd -l -- $TWiki::cmdQuote%TOKEN%$TWiki::cmdQuote %FILES%";
&Service::Trace::TRACE("Grep Command : $cmd");
  my $acmd;
  my $tempVal;
  my $sDir = "$TWiki::dataDir";
&Service::Trace::TRACE("Data Directory : $sDir");

  if( $pattern ) {
    # Do grep search
    chdir( "$sDir" );
&Service::Trace::TRACE("Chdir to : $sDir");
    my $acmd = $cmd;
    $acmd =~ s/%TOKEN%/$pattern/o;
    $acmd =~ s/%FILES%/@topicList/;
    $acmd =~ /(.*)/;
    $acmd = "$1";
    $tempVal = `$acmd`;
&Service::Trace::TRACE("Command : $acmd");
    @topicList = split( /\n/, $tempVal );
&Service::Trace::TRACE("List of files : @topicList");
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
&Service::Trace::TRACE("List of topics : @topicList");
   return @topicList;
}

# Update topics' content and meta
sub updateTopics {
  my ( $key, $login, $oldWeb, $oldTopic, $newWeb, $newTopic, @topics ) = @_;
  my @updated_topics = ();
&Service::Trace::TRACE("UpdateTopics Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Login : $login");
&Service::Trace::TRACE("OldWeb : $oldWeb");
&Service::Trace::TRACE("OldTopic : $oldTopic");
&Service::Trace::TRACE("NewWeb : $newWeb");
&Service::Trace::TRACE("NewTopic : $newTopic");
&Service::Trace::TRACE("Topics : @topics");
  return if ( ( $oldWeb eq $newWeb ) && ( $oldTopic eq $newTopic ) );
  my $theSearchValInWeb = "(\[\\s\\[\])($oldWeb\\.)?($oldTopic)(\[\^\\d\\w\\.\])";
  my $theSearchValOutWeb = "(\[\\s\\[\])($oldWeb\\.)($oldTopic)(\[\^\\d\\w\\.\])";
  my $theReplaceVal = "$newWeb.$newTopic";
&Service::Trace::TRACE("TheSearchValInWeb : $theSearchValInWeb");
&Service::Trace::TRACE("TheSearchValOutWeb : $theSearchValOutWeb");
&Service::Trace::TRACE("TheReplaceVal : $theReplaceVal");
  my $unlock = "on";
&Service::Trace::TRACE("Unlock : $unlock");
  my $dontNotify = "on";
&Service::Trace::TRACE("DontNotify : $dontNotify");
  my $saveCmd = '';
&Service::Trace::TRACE("SaveCmd : $saveCmd");

  # Update each one
  foreach my $topic (@topics) {
    my ( $web, $topic ) = split /\./, $topic;
&Service::Trace::TRACE("Topic : $web.$topic");
    # Initialize
    &Service::Connection::initialize( $login, $web, $topic );
&Service::Trace::TRACE("TWiki $web.$topic initialization");
    # Permissions check (change)
    if ( &Service::Topics::hasPermissions( $web, $topic, $login, 'change' ) ) {
&Service::Trace::TRACE("User $login has change permissions");
      # Lock
      my $lock = &Service::Topics::lock( $key, $login, $web, $topic, 1 );
      if ( $lock ) {
        push @updated_topics, "$web.$topic";
&Service::Trace::TRACE("Topic $web.$topic locked");
        # Get meta/text
        my ( $meta, $text ) = &TWiki::Store::readTopic( $web, $topic );
        # Change parent if it is the one searched
        if( $meta->count( "TOPICPARENT" ) ) {
&Service::Trace::TRACE("Topic $web.$topic has parent");
          my %parent = $meta->findOne( "TOPICPARENT" );
          # To compare exact values
          if ( ( $parent{"name"} eq "$oldTopic" && $oldWeb eq $web ) ||
                 $parent{"name"} eq "$oldWeb.$oldTopic" ) {
&Service::Trace::TRACE("Topic $web.$topic 's parent equals to : $oldWeb.$oldTopic");
            $parent{"name"} = $theReplaceVal;
            $meta->put( "TOPICPARENT", %parent );
&Service::Trace::TRACE("Topic $web.$topic 's parent updated");
          }
        }
        # Space for manage links located in the beginning of the document
        $text = ' '.$text;
        # Pattern replacement
        if ( $oldWeb eq $web ) {
          # Replace occurrences of this type : (web.)?topic
&Service::Trace::TRACE("Topic $web.$topic 's : searching : $theSearchValInWeb");
          while ( $text =~ s/$theSearchValInWeb/$1$theReplaceVal$4/ ) {};
        } else {
          # Replace occurrences of this type : web.topic
&Service::Trace::TRACE("Topic $web.$topic 's : searching : $theSearchValOutWeb");
          while ( $text =~ s/$theSearchValOutWeb/$1$theReplaceVal$4/ ) {};
        }
&Service::Trace::TRACE("Topic $web.$topic 's content updated");
        # Deleting first space added
        $text =~ s/ //;
        # Save
        my $changeError = &TWiki::Store::saveTopic( $web, $topic, $text, $meta, $saveCmd, $unlock, $dontNotify );
&Service::Trace::TRACE("Topic $web.$topic 's saving code : $changeError");
        # Unlock
        &Service::Topics::lock( $key, $login, $web, $topic );
      }
    }
  }
  return @updated_topics;
}

# Web Service
sub removeTopic {
  my $object = shift;
  my ( $key, $web, $topic, $option, $trashName ) = @_;
  my $trashLock;
  my $lock;
&Service::Trace::TRACE("RemoveTopic Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("Option : $option");
  $option = 0 if ( ( $option eq 1 || $option eq 2 ) && ! $Service::allow_complete_remove );
&Service::Trace::TRACE("Option a.t : $option");
&Service::Trace::TRACE("Trashname : $trashName");
  # Normalize web & topic name
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
&Service::Trace::TRACE("Topic : $web.$topic");
  # Test parameters existence
  return 3 if ( ! &TWiki::Store::topicExists( $web, $topic ) );
  # Test subweb authorization
  return 10 if ( ( $web =~ m/\// ) && ( ! $Service::subwebs ) );
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
&Service::Trace::TRACE("Admin lock CheckCode : $checkCode");
&Service::Trace::TRACE("Admin lock : LockedKey ne Key : ".($lockedKey ne $key));
&Service::Trace::TRACE("Admin lock : Dates : ".(( $date - $lockedTime ) < $Service::timeout));
  return 2 if ( ( $Service::admin_lock && ! $checkCode ) || ( $Service::admin_lock && $checkCode && ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) );
&Service::Trace::TRACE("Admin lock : $checkCode, $lockedKey, $lockedTime");
  # Manage new trash name
  $trashName = $topic if ( $trashName eq '' );
&Service::Trace::TRACE("TrashName : $trashName");
  # Test trash topic
  if ( ( $option ne 2 ) && &TWiki::Store::topicExists( 'Trash', $trashName ) ) {
&Service::Trace::TRACE("Topic $trashName is in trash");
    # Topic's new name exists in Trash
    if ( $option eq 1 ) {
&Service::Trace::TRACE("Delete topic $trashName");
      # Initialize
      &Service::Connection::initialize( $login, 'Trash', $trashName );
      # Check permissions
      return 7 if ( ! &Service::Topics::hasPermissions( 'Trash', $trashName, $login, 'rename' ) );
&Service::Trace::TRACE("Permissions on topic $trashName OK");
      # Check if topic is locked
      $trashLock = &Service::Topics::lock( $key, $login, 'Trash', $trashName, 1 );
      return 7 if ( ! $trashLock );
&Service::Trace::TRACE("Erasing Trash.$topic");
      # Erase topic completely
      &TWiki::Store::erase( 'Trash', $trashName );
&Service::Trace::TRACE("Erase ok");
      # Unlock
      &Service::Topics::lock( $key, $login, 'Trash', $trashName );
      return 0 if ( $web eq 'Trash' );
    }
    else {
      # Manage option 0 - generate a non existing trash name
      if ( $option eq 0 && $Service::allow_generate_trashID ) {
        my $id = 0;
        while ( &TWiki::Store::topicExists( 'Trash', $trashName."$Service::trashID_separator$id" ) ) {
          $id++;
        }
        $trashName .= "$Service::trashID_separator$id";
&Service::Trace::TRACE("Generated TrashName : $trashName");
      } else {
&Service::Trace::TRACE("Topic $trashName already exists in Trash : unable to move it");
        return 7;
      }
    }
  }
  # Initialize topic
  &Service::Connection::initialize( $login, $web, $topic );
  # Check permissions
  return 4 if ( ! &Service::Topics::hasPermissions( $web, $topic, $login, 'rename' ) );
&Service::Trace::TRACE("Permissions on $web.$topic OK");
  if ( $option eq 2 ) {
    # Completely erase topic
    # Check if topic is locked
    $lock = &Service::Topics::lock( $key, $login, $web, $topic, 1 );
    return 5 if ( ! $lock );
&Service::Trace::TRACE("Erase $web.$topic");
    # Erase topic completely
    &TWiki::Store::erase( $web, $topic );
&Service::Trace::TRACE("Erase ok");
    # Unlock
    &Service::Topics::lock( $key, $login, $web, $topic );
    # Notify event
    if ( $Service::notifications ) {
      my $event = Service::Notification::RefactoringEvent->new( "$web", "$topic", "", "", "", "", "remove" );
      &Service::Notification::send( $key, 3, "$login", "$login removed $web.$topic", $event );
    }
    return 0;
  }
  # Test if target name is a WikiWord
  return 6 if ( ! &TWiki::isWikiName( $trashName ) );
&Service::Trace::TRACE("TrashName $trashName is a WikiWord");
  # Check if topic is locked
  $lock = &Service::Topics::lock( $key, $login, $web, $topic, 1 );
  return 5 if ( ! $lock );
&Service::Trace::TRACE("Topic $web.$topic locked");
  my $rename_code = &TWiki::Store::renameTopic( $web, $topic, 'Trash', $trashName, "relink" );
&Service::Trace::TRACE("Rename Code : $rename_code");
  return 8 if ( $rename_code );
  # Notify event
  if ( $Service::notifications ) {
    my $event = Service::Notification::RefactoringEvent->new( "$web", "$topic", "", "Trash", "$trashName", "", "remove" );
    &Service::Notification::send( $key, 3, "$login", "$login moved $web.$topic to Trash", $event );
  }
  return 0;
}

# Web Service
sub mergeTopics {
  my $object = shift;
  my ( $key, $webTarget, $topicTarget, $webFrom, $topicFrom, $attachments, $identify, $removeOption, $dontNotify ) = @_;
  my $saveCmd = '';
  my $unlock = "on";
&Service::Trace::TRACE("MergeTopics Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("webTarget : $webTarget");
&Service::Trace::TRACE("topicTarget : $topicTarget");
&Service::Trace::TRACE("webFrom : $webFrom");
&Service::Trace::TRACE("topicFrom : $topicFrom");
&Service::Trace::TRACE("Attachments : $attachments");
&Service::Trace::TRACE("Identify : $identify");
&Service::Trace::TRACE("RemoveOption : $removeOption");
&Service::Trace::TRACE("DontNotify : $dontNotify");
&Service::Trace::TRACE("SaveCmd : $saveCmd");
&Service::Trace::TRACE("Unlock : $unlock");
  # Normalize web & topic name
  ( $webTarget, $topicTarget ) = &TWiki::Store::normalizeWebTopicName( $webTarget, $topicTarget );
  ( $webFrom, $topicFrom ) = &TWiki::Store::normalizeWebTopicName( $webFrom, $topicFrom );
&Service::Trace::TRACE("Target Topic : $webTarget.$topicTarget");
&Service::Trace::TRACE("From Topic : $webFrom.$topicFrom");
  # Tests topics
  $topicFrom = $TWiki::mainTopicname if ( $topicFrom eq '' );
  $topicTarget = $TWiki::mainTopicname if ( $topicTarget eq '' );
  # Test parameters existence
  return 3 if ( ! &TWiki::Store::topicExists( $webTarget, $topicTarget ) );
&Service::Trace::TRACE("Target Topic : $webTarget.$topicTarget exists");
  return 4 if ( ! &TWiki::Store::topicExists( $webFrom, $topicFrom ) );
&Service::Trace::TRACE("From Topic : $webFrom.$topicFrom exists");
  # Test subweb authorization
  return 10 if ( (( $webTarget =~ m/\// ) || ( $webFrom =~ m/\// )) && ( ! $Service::subwebs ) );
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
&Service::Trace::TRACE("Admin lock CheckCode : $checkCode");
&Service::Trace::TRACE("Admin lock : LockedKey ne Key : ".($lockedKey ne $key));
&Service::Trace::TRACE("Admin lock : Dates : ".(( $date - $lockedTime ) < $Service::timeout));
  return 2 if ( ( $Service::admin_lock && ! $checkCode ) || ( $Service::admin_lock && $checkCode && ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) );
&Service::Trace::TRACE("Admin lock : $checkCode, $lockedKey, $lockedTime");
  return 5 if (( $webTarget eq $webFrom ) && ( $topicTarget eq $topicFrom ));
&Service::Trace::TRACE("Topics $webTarget.$topicTarget and $webFrom.$topicFrom aren't equals");
  return 6 if ( ! &Service::Topics::hasPermissions( $webFrom, $topicFrom, $login, 'view' ) );
&Service::Trace::TRACE("Permissions on $webFrom.$topicFrom OK");
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
  return 6 if ( ! &Service::Topics::hasPermissions( $webTarget, $topicTarget, $login, 'change' ) );
&Service::Trace::TRACE("Permissions on $webTarget.$topicTarget OK");
  # Check if topic is locked
  my $lock = &Service::Topics::lock( $key, $login, $webTarget, $topicTarget, 1 );
  return 7 if ( ! $lock );
&Service::Trace::TRACE("Locking OK");
  # Copy attachments
  $metaTarget = &copyAttachments( $metaFrom, $metaTarget, $webFrom, $topicFrom, $webTarget, $topicTarget ) if ( $attachments );
  # Saving
  my $change_code = &TWiki::Store::saveTopic( $webTarget, $topicTarget, $textTarget, $metaTarget, $saveCmd, $unlock, $dontNotify );
&Service::Trace::TRACE("Change Parent Code : $change_code");
  return 8 if( $change_code );
  # Notify event
  if ( $Service::notifications ) {
    my $event = Service::Notification::RefactoringEvent->new( "$webFrom", "$topicFrom", "", "webTarget", "$topicTarget", "", "merge" );
    &Service::Notification::send( $key, 3, "$login", "$login merged $webFrom.$topicFrom with $webTarget.$topicTarget", $event );
  }
  # Delete auxiliary topic
  my $remove_code;
  $remove_code = &removeTopic($object, $key, $webFrom, $topicFrom, $removeOption) if ( $removeOption ne -1);
&Service::Trace::TRACE("Remove code : $remove_code");
  return 9 if ( $remove_code );
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

# Web Service
sub copyTopic {
  my $object = shift;
  my ( $key, $srcWeb, $topic, $dstWeb, $newName, $parent, $attachments ) = @_;
  my $saveCmd = '';
  my $unlock = "on";
  my $dontNotify = "on";
&Service::Trace::TRACE("CopyTopic Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("srcWeb : $srcWeb");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("dstWeb : $dstWeb");
&Service::Trace::TRACE("newName : $newName");
&Service::Trace::TRACE("Parent : $parent");
&Service::Trace::TRACE("Attachments : $attachments");
&Service::Trace::TRACE("SaveCmd : $saveCmd");
&Service::Trace::TRACE("Unlock : $unlock");
&Service::Trace::TRACE("DontNotify : $dontNotify");
  # Test empty parameters
  $parent = $TWiki::mainTopicname if ( $parent eq '' );
  # Normalize webs & topics name
  ( $srcWeb, $topic ) = &TWiki::Store::normalizeWebTopicName( $srcWeb, $topic );
  ( $dstWeb, $newName ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $newName );
  ( $dstWeb, $parent ) = &TWiki::Store::normalizeWebTopicName( $dstWeb, $parent );
&Service::Trace::TRACE("Normalized srcWeb : $srcWeb");
&Service::Trace::TRACE("Normalized Topic : $topic");
&Service::Trace::TRACE("Normalized dstWeb : $dstWeb");
&Service::Trace::TRACE("Normalized newName : $newName");
&Service::Trace::TRACE("Normalized Parent : $parent");
  # Test webs and topics existence
  return 3 if ( ! &TWiki::Store::topicExists( $srcWeb, $topic ) );
&Service::Trace::TRACE("Source topic and web OK");
  return 4 if ( &TWiki::Store::topicExists( $dstWeb, $newName ) );
&Service::Trace::TRACE("Destination $dstWeb.$newName OK");
  return 5 if ( ! &TWiki::Store::topicExists( $dstWeb, $parent ) );
&Service::Trace::TRACE("Destination parent : $parent OK");
  # Test subweb authorization
  return 10 if ( ( ( $srcWeb =~ m/\// ) || ( $dstWeb =~ m/\// ) ) && ( ! $Service::subwebs ) );
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
&Service::Trace::TRACE("Login $login exists");
  # Check preventive lock
  my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
  my $date = time();
&Service::Trace::TRACE("Admin lock CheckCode : $checkCode");
&Service::Trace::TRACE("Admin lock : LockedKey ne Key : ".($lockedKey ne $key));
&Service::Trace::TRACE("Admin lock : Dates : ".(( $date - $lockedTime ) < $Service::timeout));
  return 2 if ( ( $Service::admin_lock && ! $checkCode ) || ( $Service::admin_lock && $checkCode && ( $lockedKey ne $key ) && ( ( $date - $lockedTime ) < $Service::timeout ) ) );
&Service::Trace::TRACE("Admin lock : $checkCode, $lockedKey, $lockedTime");
  # Initialize
  &Service::Connection::initialize( $login, $dstWeb, $newName );
  # Test if target name is a WikiWord
  return 6 if ( ! &TWiki::isWikiName( $newName ) );
&Service::Trace::TRACE("NewName $newName is a WikiWord");
  # Check permissions
  return 7 if ( ! &Service::Topics::hasPermissions( $srcWeb, $topic, $login, 'view' ) );
&Service::Trace::TRACE("$login has view permissions on $srcWeb.$topic");
  # Check if topic is locked
  my $lock = &Service::Topics::lock( $key, $login, $dstWeb, $newName, 1 );
  return 8 if ( ! $lock );
&Service::Trace::TRACE("Locking OK");
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
&Service::Trace::TRACE("Change Code : $change_code");
  return 9 if ( $change_code );
  # Notify event
  if ( $Service::notifications ) {
    my $event = Service::Notification::RefactoringEvent->new( "$srcWeb", "$topic", "", "dstWeb", "$newName", "$parent", "copy" );
    &Service::Notification::send( $key, 3, "$login", "$login copied $srcWeb.$topic to $dstWeb.$newName", $event );
  }
  return 0;
}

# Copy attachment from topic to another
sub copyAttachments {
  my ( $meta1, $meta2, $oldWeb, $oldTopic, $newWeb, $newTopic ) = @_;
&Service::Trace::TRACE("CopyAttachments Procedure");
&Service::Trace::TRACE("Meta1 : $meta1");
&Service::Trace::TRACE("Meta2 : $meta2");
&Service::Trace::TRACE("oldWeb : $oldWeb");
&Service::Trace::TRACE("oldTopic : $oldTopic");
&Service::Trace::TRACE("newWeb : $newWeb");
&Service::Trace::TRACE("newTopic : $newTopic");
  # Retrieve source attachments
  my @attachs = $meta1->find( "FILEATTACHMENT" );
&Service::Trace::TRACE("Number of Attachments in $oldWeb.$oldTopic : $#attachs");
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
&Service::Trace::TRACE("AttachName : $name");
    # Pub directory actions
    my ( $copy_code, $newAttach ) = &Service::Topics::copyAttachmentFile( $oldWeb, $oldTopic, $newWeb, $newTopic, $oldName, $name );
&Service::Trace::TRACE("Copy Attachment Result : $copy_code");
    # Try to delete if errors when creation
    $newAttach->_delete() if ( $copy_code );
    # Meta actions
    &TWiki::Attach::updateAttachment(
                $attrVersion, $name, $attrPath, $attrSize,
                $attrDate, $attrUser, $attrComment, $attrAttr, $meta2 ) if ( ! $copy_code );
  }
  return $meta2;
}

1;