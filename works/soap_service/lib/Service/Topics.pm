package Service::Topics;

# Topics Management Module with Attachments
# Author : Romain Raugi, based on Peter Thoeny's works for TWiki

use strict;

use MIME::Base64;
use File::Copy;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

# Web Service
sub lockTopic {
  my $object = shift;
  my ( $key, $web, $topic, $doLock ) = @_;
&Service::Trace::TRACE("LockTopic WS Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("DoLock : $doLock");
  # Normalize
  ( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
&Service::Trace::TRACE("Normalized Web : $web");
&Service::Trace::TRACE("Normalized Topic : $topic");
  # Check if subwebs are allowed
  return Service::Conversions::soap_boolean('response', 0) if ( ( $web =~ m/\// ) && ( ! $Service::subwebs ) );
  # Test topic existence
  return Service::Conversions::soap_boolean('response', 0) if ( ! &TWiki::Store::topicExists( $web, $topic ) );
&Service::Trace::TRACE("Topic $topic exists");
  # Retrieves login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login $login");
  return Service::Conversions::soap_boolean('response', 0) if ( ! $login );
  # Initialize user
  &Service::Connection::initialize( $login, $web, $topic );
  # Locking
  my $lock = &lock( $key, $login, $web, $topic, $doLock );
&Service::Trace::TRACE("Lock Result : $lock");
  return Service::Conversions::soap_boolean('response', $lock);
}

# Web Service
sub getWebs {
  my $object = shift;
  my ( $web ) = @_;
  my @webs = &TWiki::Store::getAllWebs( $web );
  return Service::Conversions::soap_array('response', @webs);
}

# Private locking procedure
# TWiki initialization and tests must have been done before
# return 1 if success, else 0
sub lock {
  my ( $key, $login, $web, $topic, $doLock ) = @_;
  # Check if topic is locked
  my ( $lockUser, $lockTime ) = &TWiki::Store::topicIsLockedBy( $web, $topic );
&Service::Trace::TRACE("topicIsLockedBy returns lockUser : $lockUser");
&Service::Trace::TRACE("topicIsLockedBy returns lockTime : $lockTime");
  return 0 if ( $lockUser );
&Service::Trace::TRACE("Same TWiki user : $lockUser");
  # Users equals, needing more informations :
  # Retrieve user(s) who have locked topic
  # if no user or only me, ok
  my @users = &Service::Locks::getLockingUsers( $web, $topic );
&Service::Trace::TRACE("Locks put to topic (Associations) : @users, Last idx : $#users");
  return 0 if (! ( $#users < 0 || ( $#users == 0 && $users[$#users] eq $key ) ));
&Service::Trace::TRACE("Ok to (un)lock");
  if ( $doLock ) {
    # Put TWiki lock
    &TWiki::Store::lockTopicNew( $web, $topic );
    # Update locks/key
    &Service::Locks::add( $key, $web, $topic );
    # Notify event
    if ( $Service::notifications ) {
      my $event = Service::Notification::TopicEvent->new( "$web", "$topic", "lock" );
      &Service::Notification::send( $key, 4, "$login", "$login locked $web.$topic", $event );
    }
  } else {
    &TWiki::Store::lockTopicNew( $web, $topic, 1 );
    # Notify event
    if ( $Service::notifications ) {
      my $event = Service::Notification::TopicEvent->new( "$web", "$topic", "unlock" );
      &Service::Notification::send( $key, 4, "$login", "$login unlocked $web.$topic", $event );
    }
  }
  return 1;
}

# Test permissions on topics
# Others tests must have been done before (like topic existence)
sub hasPermissions {
  my ( $web, $topic, $login, $type ) = @_;
  my $wikiUserName = &TWiki::userToWikiName( $login );
&Service::Trace::TRACE("WikiUserName : $wikiUserName");
  my $ret;
  # Test topic existence
  $ret = &TWiki::Store::readWebTopic( $web, $topic );
  return 0 if (! $ret);
  if ( $type eq 'view' ) {
    return 0 if ( ! &TWiki::Access::checkAccessPermission( "view", $wikiUserName, $ret, $topic, $web ) );
  } else {
&Service::Trace::TRACE("Topic $topic exists");
    # Test Authorizations
    return 0 if ( ! &TWiki::Access::checkAccessPermission( "change", $wikiUserName, $ret, $topic, $web ) );
&Service::Trace::TRACE("Change Permissions");
    if ( $type eq 'rename' ) {
      return 0 if ( ! &TWiki::Access::checkAccessPermission( "rename", $wikiUserName, $ret, $topic, $web ) );
&Service::Trace::TRACE("Rename Permissions");
    }
  }
  return 1;
}

# Test if an attach name is in meta information
sub isAttachName {
  my ( $name, $meta ) = @_;
&Service::Trace::TRACE("IsAttachName Procedure");
  my @attachs = $meta->find( "FILEATTACHMENT" );
  my $i = 0;
  my $n = $#attachs + 1;
  my $found = 0;
  # Look for attach name
  while ( $i < $n && ! $found ) {
    $found = 1 if ( $attachs[$i]->{"name"} eq $name );
    $i++;
  }
&Service::Trace::TRACE("AttachName $name Found Result : $found");
  return $found;
}

# Web Service
sub setTopic {
  my $object = shift;
  my ( $key, $topic, $doKeep, $doUnlock, $dontNotify ) = @_;
&Service::Trace::TRACE("SetTopic Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("DoKeep : $doKeep");
&Service::Trace::TRACE("DoUnlock : $doUnlock");
&Service::Trace::TRACE("DontNotify : $dontNotify");
  return 3 if ( ! $topic );
  my $webName = $topic->{'web'};
  my $topicName = $topic->{'name'};
  my $author = $topic->{'author'};
  my $date = $topic->{'date'};
  my $format = $topic->{'format'};
  my $version = $topic->{'version'};
  my $parent = $topic->{'parent'};
  my $attachments = $topic->{'attachments'};
  my $data = &Service::Arborescence::reformat( $topic->{'data'} );
  # Normalize web & topic name
  ( $webName, $topicName ) = &TWiki::Store::normalizeWebTopicName( $webName, $topicName );
&Service::Trace::TRACE("Normalized Web : $webName");
&Service::Trace::TRACE("Normalized Topic : $topicName");
  # Test parameters existence
  return 2 if ( ! &TWiki::Store::topicExists( $webName, $topicName ) );
  # Test subweb authorization
  return 10 if ( ( $webName =~ m/\// ) && ( ! $Service::subwebs ) );
&Service::Trace::TRACE("Topics and Webs OK");
  # Retrieve login
  my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return 1 if ( ! $login );
&Service::Trace::TRACE("Login $login exists");
  # Initialize
  &Service::Connection::initialize( $login, $webName, $topicName );
  # Check permissions
  return 4 if ( ! &hasPermissions( $webName, $topicName, $login, 'change' ) );
&Service::Trace::TRACE("$login has rename/change permissions");
  # Check if topic is locked
  my $lock = &lock( $key, $login, $webName, $topicName, 1 );
  return 5 if ( ! $lock );
  my ( $meta, $text ) = &TWiki::Store::readTopic( $webName, $topicName );
  # Create and link attachments
  $meta = &setAttachments( $key, $attachments, $webName, $topicName, $meta, $data, $doKeep, $dontNotify );
  my $change_code = &TWiki::Store::saveTopic( $webName, $topicName, $data, $meta, '', $doUnlock, $dontNotify );
&Service::Trace::TRACE("Change Code : $change_code");
  return 6 if( $change_code );
  # Notify events
  if ( $Service::notifications ) {
    my $event = Service::Notification::TopicEvent->new( "$webName", "$topicName", "save" );
    &Service::Notification::send( $key, 4, "$login", "$login modified $webName.$topicName", $event );
  }
  return 0;
}

# Create and link uploaded attachments
sub setAttachments {
  my ( $key, $attachments, $web, $topic, $meta, $text, $doKeep, $dontNotify ) = @_;
  my %received_attachments = ();
&Service::Trace::TRACE("SetAttachments Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Attachments : $attachments");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
&Service::Trace::TRACE("DontNotify : $dontNotify");
  # Attachments process
  foreach my $attachment (@$attachments) {
    my $name = $attachment->{name};
    $received_attachments{$name} = 1;
    my $path = $attachment->{path};
    my $hidden = $attachment->{hidden};
    my $date = $attachment->{date};
    my $user = $attachment->{user};
    my $size = $attachment->{size};
    my $version = $attachment->{version};
    my $comment = $attachment->{comment};
    my $content = $attachment->{content};
&Service::Trace::TRACE("Name : $name");
&Service::Trace::TRACE("Path : $path");
&Service::Trace::TRACE("Hidden : $hidden");
&Service::Trace::TRACE("Date : $date");
&Service::Trace::TRACE("User : $user");
&Service::Trace::TRACE("Size : $size");
&Service::Trace::TRACE("Version : $version");
&Service::Trace::TRACE("Comment : $comment");
    # Hidden attribute
    my $attr = "h" if ( $hidden );
    # Upload : create and/or change properties
    if ( $content ) {
&Service::Trace::TRACE("Content detected");
      # Upload
      my $tmpFilename = "$Service::uploadDir/upload$key";
&Service::Trace::TRACE("Create or modify attachment with tmpFilename : $tmpFilename");
      my $failed = 0;
      my $decoded_data = '';
      if ( $content =~ m/^[0-9a-zA-Z\/\+\=\ \n\t]*$/ ) {
        $decoded_data = &decode_base64( $content );
      } else {
        $decoded_data = $content;
      }
      open(UPLOAD, ">$tmpFilename") or $failed = 1;
      binmode UPLOAD;
      if ( ! $failed ) {
        # Write received data
        print UPLOAD $decoded_data;
        close(UPLOAD);
        $size = -s $tmpFilename;
&Service::Trace::TRACE("Size : $size");
        if( -e $tmpFilename && $size ) {
&Service::Trace::TRACE("OK to write attachment");
          # Save Attachment
          my $error = &TWiki::Store::saveAttachment( $web, $topic, $text, '',
                                                     $name, $Service::doNotLogChanges, 'on',
                                                     $dontNotify, $comment, $tmpFilename );
&Service::Trace::TRACE("Error : $error");
        }
        # Delete temp file
        unlink $tmpFilename;
      }
&Service::Trace::TRACE("Attachment created : size : $size");
      # Create properties
      &TWiki::Attach::updateAttachment(
                $version, $name, $path, $size,
                $date, $user, $comment, $attr, $meta );
    } elsif ( &isAttachName( $name, $meta ) ) {
      # No content but need to already exists
      # Change properties
      &TWiki::Attach::updateProperties( $name, $attr, $comment, $meta );
    }
  }
  # "Delete" not received attachments (headers)
  if ( ! $doKeep ) {
    my @e_attachments = $meta->find( "FILEATTACHMENT" );
    foreach my $attachment (@e_attachments) {
      my $oldName = $attachment->{"name"};
      my $newName = $oldName;
      if ( ! exists $received_attachments{$oldName} ) {
        # Delete attachment (and generate id if exists in TrashAttachment)
        if ( -e "$TWiki::pubDir/Trash/TrashAttachment/$oldName" ) {
          my $id = 1;
          while ( -e "$TWiki::pubDir/Trash/TrashAttachment/$newName" ) {
            if ( $oldName =~ m/(.*)\.(.*)/ ) {
              $newName = "$1$Service::trashIDSeparator$id.$2";
            } else {
              $newName = "$oldName$id";
            }
            $id++;
          }
        }
        my ( $copy_code, $newAttach ) = &copyAttachmentFile( $web, $topic, 'Trash', 'TrashAttachment', $oldName, $newName, 1 );
        # Try to delete if errors when creation
        $newAttach->_delete() if ( $copy_code );
&Service::Trace::TRACE("Attachment $oldName destroyed");
        # Update meta
        $meta->remove( "FILEATTACHMENT", $oldName );
      }
    }
  }
  return $meta;
}

# Copy an attachment file
# Tests must have been done before
# Return error code and new attachment
sub copyAttachmentFile {
  my ( $oldWeb, $oldTopic, $newWeb, $newTopic, $oldName, $name, $doMove ) = @_;
&Service::Trace::TRACE("CopyAttachmentFile Procedure");
&Service::Trace::TRACE("oldWeb : $oldWeb");
&Service::Trace::TRACE("oldTopic : $oldTopic");
&Service::Trace::TRACE("newWeb : $newWeb");
&Service::Trace::TRACE("newTopic : $newTopic");
&Service::Trace::TRACE("oldName : $oldName");
&Service::Trace::TRACE("name : $name");
&Service::Trace::TRACE("doMove : $doMove");
  my $topicHandler = &TWiki::Store::_getTopicHandler( $oldWeb, $oldTopic, $oldName );
  my $new = TWiki::Store::RcsFile->new( $newWeb, $newTopic, $name,
        ( pubDir => $TWiki::pubDir ) );
  my $oldAttachment = $topicHandler->{file};
  my $newAttachment = $new->{file};
  # Before save, create directories if they don't exist
  my $tempPath = $new->_makePubWebDir();
&Service::Trace::TRACE("TempPath1 : $tempPath");
  unless( -e $tempPath ) {
    umask( 0 );
&Service::Trace::TRACE("TempPath1 : create it");
    mkdir( $tempPath, 0775 );
  }
  $tempPath = $new->_makeFileDir( 1 );
&Service::Trace::TRACE("TempPath2 : $tempPath");
  unless( -e $tempPath ) {
    umask( 0 );
    mkdir( $tempPath, 0775 );
&Service::Trace::TRACE("TempPath2 : create it");
  }
  # Copy attachment
  if ( $doMove ) {
    if( ! move( $oldAttachment, $newAttachment ) ) {
&Service::Trace::TRACE("Attachment Move Error");
        return ( 1, $new );
    }
  } else {
    if( ! copy( $oldAttachment, $newAttachment ) ) {
&Service::Trace::TRACE("Attachment Copy Error");
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
&Service::Trace::TRACE("Attachment RCS Move Error");
        return ( 2, $new );
      }
    } else {
      if( ! copy( $oldAttachmentRcs, $newAttachmentRcs ) ) {
&Service::Trace::TRACE("Attachment RCS Copy Error");
        return ( 2, $new );
      }
    }
  }
  return ( 0, $new );
}

1;