# TWiki TRefactorAddOn Topics & Attachments Management Module
# 
# TWiki TRefactorAddOn add-on for TWiki
# Copyright (C) 2004 Maxime Lamure, Mario Di Miceli, Damien Mandrioli & Romain Raugi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# $Id: Topics.pm,v 1.1 2004/11/21 10:48:49 romano Exp $

package TWiki::Contrib::TRefactorAddOn::Topics;

use strict;

use MIME::Base64;
use File::Copy;
use File::stat;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

sub lockTopic {
	my ( $key, $web, $topic, $doUnlock ) = @_;
	# Normalize
	$topic = $TWiki::mainTopicname if ( ( ! $topic ) || ( $topic eq '' ) );
	( $web, $topic ) = &TWiki::Store::normalizeWebTopicName( $web, $topic );
	# Test topic existence
	return -1 if ( ! &TWiki::Store::topicExists( $web, $topic ) );
	# Retrieves login
	my $login = &TWiki::Contrib::TRefactorAddOn::Connection::getLogin( $key );
 	return -2 if ( ! $login );
	# Initialize user
	&TWiki::Contrib::TRefactorAddOn::Connection::initialize( $login, $web, $topic );
	# Locking
	my ( $locked, $info ) = &lock( $key, $login, $web, $topic, $doUnlock );
	return ( $locked, $info ) if ( ! $locked );
	return ( $locked, "lock has been ".( $doUnlock ? "released":"put" )." on $web.$topic" );
}

# Private locking procedure
# TWiki initialization and tests must have been done before
# return 1 if success, else 0
sub lock {
	my ( $key, $login, $web, $topic, $doUnlock ) = @_;
	# Test if topic is locked
	my ( $ok, $lockUser ) = &isUnlocked( $key, $login, $web, $topic );
	if ( ! $ok ) {
	 return ( 0, $lockUser );
	}
	if ( ! $doUnlock ) {
		# Put TWiki lock
		&TWiki::Store::lockTopicNew( $web, $topic );
		# Update locks/key
		&TWiki::Contrib::TRefactorAddOn::Locks::add( $key, $web, $topic );
	} else {
		&TWiki::Store::lockTopicNew( $web, $topic, 1 );
	}
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
	my $lck_key = &TWiki::Contrib::TRefactorAddOn::Locks::getLockingUser( $web, $topic );
	if ( $lck_key && ( $lck_key ne $key ) ) {
		return ( 0, $login );
	}
	return 1;
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
  if ( ( ! $topic ) || ( $topic eq "" ) ) {
    # Search topics with no parents in this web
    @topicList = &_grepTopics( "%META:TOPICPARENT", "$TWiki::dataDir\/$web\/*.txt", 1 );
    
    my @topicList2 = &_grepTopics( "%META:TOPICPARENT\\\{name=\\\"($web\\\.)?$TWiki::mainTopicname\\\"\\\}%", 
                                 "$TWiki::dataDir\/$web\/*.txt" );
    @topicList = ( @topicList, @topicList2 );                    
  } else {
    # Search in this web
    @topicList = &_grepTopics( "%META:TOPICPARENT\\\{name=\\\"($web\\\.)?$topic\\\"\\\}%", 
                              "$TWiki::dataDir\/$web\/*.txt" );
  }
  return ( 0, @topicList );
}

# Grep regexp on topics
sub _grepTopics {
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
	my $login = &TWiki::Contrib::TRefactorAddOn::Connection::getLogin( $key );
	return 0 if ( ! $login );
	$topicName = $TWiki::mainTopicname if ( ( ! $topicName ) || ( $topicName eq '' ) );
	# Test topic existence
	( $web, $topicName ) = &TWiki::Store::normalizeWebTopicName( $web, $topicName );
	return -1 if ( ! &TWiki::Store::topicExists( $web, $topicName ) );
  # Initialize
	&TWiki::Contrib::TRefactorAddOn::Connection::initialize( $login, $web, $topicName );
	# Check permissions
  my ( $meta, $content ) = &TWiki::Store::readTopic( $web, $topicName );
  my $view_perms = &TWiki::Access::checkAccessPermission( "view", $login, $content, $topicName, $web );
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
	$topic->{'cDate'} = $topicinfo{"date"};
	$topic->{'mDate'} = $mtime;
	$topic->{'format'} = $topicinfo{"format"};
	$topic->{'version'} = $topicinfo{"version"};
	my @attachments = $meta->find( "FILEATTACHMENT" );
  $topic->{'attachments'} = \@attachments;
	return ( 1, $topic );
}

1;