package Service::Topics;

# Topics Management Module with Attachments
# Author : Romain Raugi

use strict;

use MIME::Base64;
use File::Copy;
use File::stat;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

sub lockTopic {
	my ( $key, $web, $topic, $doUnlock ) = @_;
	# Normalize
	( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
	# Test topic existence
	return -1 if ( ! &TWiki::Store::topicExists( $web, $topic ) );
	# Retrieves login
	my $login = &Service::Connection::getLogin( $key );
 	return -2 if ( ! $login );
	# Initialize user
	&Service::Connection::initialize( $login, $web, $topic );
	# Locking
	my ( $locked, $info ) = &lock( $key, $login, $web, $topic, $doUnlock );
	return ( $locked, $info );
}

# Private locking procedure
# TWiki initialization and tests must have been done before
# return 1 if success, else 0
sub lock {
	my ( $key, $login, $web, $topic, $doUnlock ) = @_;
	my $prefix = ( $doUnlock )?"Unl":"L";
	&Service::Trace::log( "$prefix"."ocking $web.$topic attempt by $login ($key)" );
	# Test if topic is locked
	my ( $ok, $lockUser ) = &isUnlocked( $key, $login, $web, $topic );
	if ( ! $ok ) {
	 &Service::Trace::log( "$web.$topic already locked by $lockUser ($key) : failed" );
	 return ( 0, $lockUser );
	}
	if ( ! $doUnlock ) {
		# Put TWiki lock
		&TWiki::Store::lockTopicNew( $web, $topic );
		# Update locks/key
		&Service::Locks::add( $key, $web, $topic );
	} else {
		&TWiki::Store::lockTopicNew( $web, $topic, 1 );
	}
	&Service::Trace::log( "$prefix"."ocking action OK" );
	return 1;
}

# Private lock test procedure
# TWiki initialization and tests must have been done before
# return 1 if success, else 0
sub isUnlocked {
  my ( $key, $login, $web, $topic ) = @_;
  # Check if topic is locked
	my ( $lockUser, $lockTime ) = &TWiki::Store::topicIsLockedBy( $web, $topic );
	if ( $lockUser ) {
		return ( 0, $lockUser );
	}
	# Users equals, needing more informations :
	# Retrieve user who have locked topic
	my $lck_key = &Service::Locks::getLockingUser( $web, $topic );
	if ( $lck_key && ( $lck_key ne $key ) ) {
		return ( 0, $login );
	}
	return 1;
}

# Retrieve topics located in a specific web
sub getTopicNames {
	my ( $web ) = @_;
	return -1 if ( ! &TWiki::Store::webExists( $web ) );
	return ( 0, &TWiki::Store::getTopicNames( $web ) );
}

# Test permissions on topics and get content
# Others tests must have been done before (like topic existence)
sub testAndGetTopic {
	my ( $web, $topic, $login, $type ) = @_;
	# Normalize web & topic name
	( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
	# Test topic existence
	return -1 if ( ! &TWiki::Store::topicExists( $web, $topic ) );
	# Get topic
	my ( $meta, $content ) = &TWiki::Store::readTopic( $web, $topic );
	if ( $type eq 'view' ) {
		return 0 if ( ! &TWiki::Access::checkAccessPermission( "view", $login, $content, $topic, $web ) );
	} else {
		# Test Authorizations
		return 0 if ( ! &TWiki::Access::checkAccessPermission( "change", $login, $content, $topic, $web ) );
		if ( $type eq 'rename' ) {
			return 0 if ( ! &TWiki::Access::checkAccessPermission( "rename", $login, $content, $topic, $web ) );
		}
	}
	return ( 1, $meta, $content );
}

# Retrieve topic
sub getTopicContent {
	my ( $key, $web, $name, $readonly ) = @_;
	# Retrieve login
	my $login = &Service::Connection::getLogin( $key );
	return -2 if ( ! $login );
  # Initialize
	&Service::Connection::initialize( $login, $web, $name );
	# Check permissions
  my ( $code, $meta, $content ) = &testAndGetTopic( $web, $name, $login, 'change' );
  return ( $code ) if ( $code != 1 );
  # Check if topic is locked
  if( ! $readonly ) {
    my ( $locked, $info ) = &Service::Topics::lock( $key, $login, $web, $name, 0 );
    return ( -3, $info ) if ( ! $locked );
  }
	# Return value
	my $topic = {};
	my %topicinfo = $meta->findOne( "TOPICINFO" );
	$topic->{'web'} = $web;
	$topic->{'name'} = $name;
	$topic->{'author'} = $topicinfo{"author"};
	$topic->{'date'} = localtime( $topicinfo{"date"} );
	$topic->{'format'} = $topicinfo{"format"};
	$topic->{'version'} = $topicinfo{"version"};
	$topic->{'content'} = $content;
	my @attachments = $meta->find( "FILEATTACHMENT" );
	$topic->{'attachments'} = [@attachments];
	return ( 1, $topic );
}

# Retrieve attachment
sub getTopicAttachment {
	my ( $key, $web, $topic, $name ) = @_;
	# Retrieve login
	my $login = &Service::Connection::getLogin( $key );
	return -2 if ( ! $login );
  	# Initialize
	&Service::Connection::initialize( $login, $web, $name );
	# Check permissions
  my ( $code, $meta, $content ) = &testAndGetTopic( $web, $topic, $login, 'view' );
  return ( $code ) if ( $code != 1 );
  # Get informations
  my $attachment = {};
  my @attachments = $meta->find( "FILEATTACHMENT" );
  foreach ( @attachments ) {
    last if ( ( $attachment = $_ )->{"name"} eq $name );
  }
  # Retrieve attachment content
  my $topicHandler = &TWiki::Store::_getTopicHandler( $web, $topic, $name );
  return -3 if ( ! $topicHandler );
  my $file = $topicHandler->{file};
  open( FILE, "<$file" ) or return -3;
  my $buf;
  $attachment->{'data'} = "";
  while ( read( FILE, $buf, 60*57 ) ) {
  $attachment->{'data'} .= encode_base64( $buf );
  } 
  close( FILE );
  return ( 1, $attachment );
}

# Save new attachment
sub uploadTopicAttachment {
	my ( $key, $web, $topic, $attachment ) = @_;
}

# Rename existing attachment
sub renameTopicAttachment {
	my ( $key, $web, $topic, $name, $newName ) = @_;
}

# Remove attachment
sub removeTopicAttachment {
	my ( $key, $web, $topic, $name ) = @_;
}

# Write topic content (attachments not managed here)
sub saveTopicContent {
	my ( $key, $topic, $doUnlock, $dontNotify ) = @_;
}

# Get Child Topics of the one passed in parameter
sub getChildTopics {
  my ( $web, $topic ) = @_;
  # Normalize
	( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
	# Test topic existence
	return -2 if ( ! &TWiki::Store::webExists( $web ) );
	return -1 if ( ( $topic ) && ! &TWiki::Store::topicExists( $web, $topic ) );
	# Retrieve topics
	my @topicList = ();
	my @allWebs = &TWiki::Store::getAllWebs();
  if ( $topic eq "" ) {
    # Search topics with no parents in this web
    @topicList = &grepTopics( "%META:TOPICPARENT", "$TWiki::dataDir\/$web\/*.txt", 1 );
    
    my @topicList2 = &grepTopics( "%META:TOPICPARENT\\\{name=\\\"$TWiki::mainTopicname\\\"\\\}%", 
                                 "$TWiki::dataDir\/$web\/*.txt" );
    @topicList = ( @topicList, @topicList2 );                    
  } else {
    # Search in this web
    @topicList = &grepTopics( "%META:TOPICPARENT\\\{name=\\\"($web\\\.)?$topic\\\"\\\}%", 
                              "$TWiki::dataDir\/$web\/*.txt" );
  }
  return ( 0, @topicList );
}

# Grep regexp on topics
sub grepTopics {
  my ( $pattern, $files, $invert ) = @_;
  my $cmd = "$TWiki::egrepCmd -l -- $TWiki::cmdQuote$pattern$TWiki::cmdQuote $files";
  $cmd = "$TWiki::egrepCmd -l -L -- $TWiki::cmdQuote$pattern$TWiki::cmdQuote $files" if ( $invert );
  my $res = `$cmd`;
  my @list = split( /\n/, $res );
  @list = map { /.*\/(.*)\.txt$/; $_ = "$1"; } @list;
  return @list;
}

# Get Webs
sub getWebs {
  my ( $root ) = @_;
  my @webs = &TWiki::Store::getAllWebs( $root );
  return @webs;
}

# Get topic properties
sub getTopicProperties {
  my ( $key, $web, $topicName ) = @_;
  # Retrieve login
	my $login = &Service::Connection::getLogin( $key );
	return 0 if ( ! $login );
  # Initialize
	&Service::Connection::initialize( $login, $web, $topicName );
	# Check permissions
  my ( $code, $meta, $content ) = &testAndGetTopic( $web, $topicName, $login, 'view' );
  my $view_perms = $code;
  my $change_perms = &TWiki::Access::checkAccessPermission( "change", $login, $content, $topicName, $web );
  my $rename_perms = &TWiki::Access::checkAccessPermission( "rename", $login, $content, $topicName, $web );
  # Check if topic is locked
  my ( $ok, $lockUser ) = &isUnlocked( $key, $login, $web, $topicName );
  # Modification date
  my $st = stat( "$TWiki::dataDir/$web/$topicName.txt" );
  my $mtime = '';
  $mtime = $st->mtime if ( $st );
	# Return value
	my $topic = {};
	my %topicinfo = $meta->findOne( "TOPICINFO" );
	$topic->{'web'} = $web;
	$topic->{'name'} = $topicName;
	if ( $topicName eq $TWiki::mainTopicname ) { $topic->{'mainTopic'} = 1; }
	else { $topic->{'mainTopic'} = 0; }
	$topic->{'rename_permissions'} = $rename_perms;
	$topic->{'change_permissions'} = $change_perms;
	$topic->{'view_permissions'} = $view_perms;
	$topic->{'locked'} = $lockUser;
	$topic->{'author'} = $topicinfo{"author"};
	$topic->{'cDate'} = localtime( $topicinfo{"date"} );
	$topic->{'mDate'} = localtime( $mtime );
	$topic->{'format'} = $topicinfo{"format"};
	$topic->{'version'} = $topicinfo{"version"};
	return ( 1, $topic );
}

1;