# TWiki TRefactorAddOn Connections Management Module
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
# $Id: Connection.pm,v 1.1 2004/11/21 10:48:47 romano Exp $

package TWiki::Contrib::TRefactorAddOn::Connection;

use strict;

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

if ( $TWiki::OS eq "WINDOWS" ) {
  require MIME::Base64;
  require Digest::SHA1;
}

sub load {
	my $clients_ref;
	my $lock = $TWiki::Contrib::TRefactorAddOn::clientsFile.".lock";
	my ( $line, $key, $usage, $login, $cnx, $echo, $failed );
	&TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
	# Read values and save them in hash
	open( FILE, "<$TWiki::Contrib::TRefactorAddOn::clientsFile" ) or $failed = 1;
	if ( ! $failed ) {
    my $date = time();
    while( $line = <FILE> ) {
      ( $key, $usage, $login, $cnx, $echo ) = split/ /, $line, 5;
      # Delete last separator
      chomp $echo;
      # Check Timeouts
      if ( ( $date - $echo ) < $TWiki::Contrib::TRefactorAddOn::timeout ) {
        $clients_ref->{$key}{'LOGIN'} = $login;
        $clients_ref->{$key}{'USAGE'} = $usage;
        $clients_ref->{$key}{'CNX'} = $cnx;
        $clients_ref->{$key}{'ECHO'} = $echo;
      }
      else {
        # Unlock all put locks
        &locks( $key, $login, 1 );
        # Unlock admin lock
        &TWiki::Contrib::TRefactorAddOn::AdminLock::doUnlock( $key );
      }
    }
    close(FILE);
  }
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
  return $clients_ref;
}

sub save {
	my $clients_ref = shift;
	my $lock = $TWiki::Contrib::TRefactorAddOn::clientsFile.".lock";
	my ( $key, $usage, $login, $cnx, $echo, $failed );
	&TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
	# Save values in text file
	open( FILE, ">$TWiki::Contrib::TRefactorAddOn::clientsFile" ) or $failed = 1;
 	if ( ! $failed ) {
		for $key ( sort keys %$clients_ref ) {
      $usage = $clients_ref->{$key}{'USAGE'};
      $login = $clients_ref->{$key}{'LOGIN'};
      $cnx = $clients_ref->{$key}{'CNX'};
      $echo = $clients_ref->{$key}{'ECHO'};
      print FILE "$key $usage $login $cnx $echo\n";
    }
    close( FILE );
  }
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
}

sub connect {
	my( $usage, $login, $pass ) = @_;
	# Current date
	my $echo = time();
	# Check spaces
	$usage =~ s/[ \t\n]+//;
	$login =~ s/[ \t\n]+//;
	# Check if login is not empty
	return -1 if ( $login eq "" );
	# Check usage if not empty
	$usage = "not_specified" if ( $usage eq "" );
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Connection attempt from $login for $usage usage" );
	# Check Login & Pass
	if ( $login !~ /^guest$/i ) {
		if ( ! &check( $login, $pass ) ) {
			&TWiki::Contrib::TRefactorAddOn::Trace::log( "Authentication of $login failed" );
			return -3;
		}
	}
	&TWiki::Contrib::TRefactorAddOn::Trace::log("Authentication from $login OK");
	# Retrieve clients from data source
	my $clients = load();
	# No possible connections now (not enough keys) : extreme case
	my @keys = keys %$clients;
	if ( $#keys == ( $TWiki::Contrib::TRefactorAddOn::maxConnections - 1 ) ) {
		&TWiki::Contrib::TRefactorAddOn::Trace::log("Connection failed, maximum number of connections reached");
		return -2;
	}
	# Generate non-existing key
   	my $key = int( rand( $TWiki::Contrib::TRefactorAddOn::keyRange ) ) + 1;
   	while ( exists $$clients{$key} ) {
		$key = int( rand( $TWiki::Contrib::TRefactorAddOn::keyRange ) ) + 1;
	}
	# New user
	$clients->{$key}{'LOGIN'} = "$login";
	$clients->{$key}{'USAGE'} = "$usage";
	$clients->{$key}{'CNX'} = "$echo";
	$clients->{$key}{'ECHO'} = "$echo";
	# Save
	&save( $clients );
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Connection established by $login, key : $key" );
	return ( $key, $TWiki::Contrib::TRefactorAddOn::timeout );
}

sub disconnect {
	my ( $key ) = @_;
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Disconnection attempt from $key" );
	# Retrieve clients from data source
	my $clients = load();
	if (exists $clients->{$key}) {
		# Get login
		my $login = $clients->{$key}{'LOGIN'};
		# Delete entry
		delete $clients->{$key};
		&save( $clients );
		# Unlock all put locks
		&locks( $key, $login, 1 );
		# Unlock admin lock
    &TWiki::Contrib::TRefactorAddOn::AdminLock::doUnlock( $key );
		&TWiki::Contrib::TRefactorAddOn::Trace::log( "Disconnection from $key OK" );
		return 1;
	}
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Disconnection from $key failed" );
	return 0;
}

sub ping {
	my ( $key ) = @_;
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Ping from $key" );
	# Retrieve clients from data source
	my $clients = load();
	if ( exists $clients->{$key} ) {
		my $login = $clients->{$key}{'LOGIN'};
		my $echo = time();
		$clients->{$key}{'ECHO'} = "$echo";
		&save( $clients );
		# Actualize all put locks
		&locks( $key, $login );
		my ( $checkCode, $lockedKey, $lockedTime ) = &TWiki::Contrib::TRefactorAddOn::AdminLock::checkAdminLock();
    &TWiki::Contrib::TRefactorAddOn::AdminLock::doLock( $key ) if ( $checkCode && ( $lockedKey eq $key ) && ( ( $echo - $lockedTime ) < $TWiki::Contrib::TRefactorAddOn::timeout ) );
		&TWiki::Contrib::TRefactorAddOn::Trace::log( "Ping from $key OK" );
		return 1;
	}
	&TWiki::Contrib::TRefactorAddOn::Trace::log( "Ping from $key failed" );
	return 0;
}

sub getUsers {
  # Retrieve clients from data source
	return load();
}

sub getLogin() {
	my ( $key ) = @_;
	# Retrieve clients from data source
	my $clients = load();
	if ( exists $clients->{$key} ) {
		return $clients->{$key}{'LOGIN'};
	}
	return undef;
}

# Authentication
# Compatible Cairo + Bejing
sub check {
	my ( $login, $pass ) = @_;
	# Reading passwords file
	my $text = &TWiki::Store::readFile( $TWiki::htpasswdFilename );
	if( $text =~ /$login\:(\S+)/ ) {
		my $oldcrypt = $1;
		my $pwd;
		# Compare crypted passwords
		if ( $TWiki::OS eq "WINDOWS" ) {
			$pwd = '{SHA}' . MIME::Base64::encode_base64( Digest::SHA1::sha1( $pass ) );
			# Strip whitespace at end of line
			$pwd =~ /(.*)$/ ;
			$pwd = $1;
		} else {
			my $salt = substr( $oldcrypt, 0, 2 );
			$pwd = crypt( $pass, $salt );
		}
		return ( $pwd eq $oldcrypt );
	}
	return 0;
}

sub locks {
	# Actualize or delete put locks (by a specific user)
	my (  $key, $login, $doUnlock ) = @_;
	my @locks = &TWiki::Contrib::TRefactorAddOn::Locks::getLocks( $key );
	foreach my $filename ( @locks ) {
		my ( $web, $topic ) = &TWiki::Contrib::TRefactorAddOn::Locks::getTopicLocation( $filename );
		# Initialize user
		&initialize( $login, $web, $topic );
		if ( $doUnlock ) {
			# Remove lock and association (implicit)
			&TWiki::Store::lockTopicNew( $web, $topic, 1 );
		} else {
			# Put TWiki lock (to actualize)
			&TWiki::Store::lockTopicNew( $web, $topic );
			# Actualize locks
			&TWiki::Contrib::TRefactorAddOn::Locks::add( $key, $web, $topic );
		}
	}
}

# Prepare TWiki for operations ...
# Tests must have been done before
sub initialize {
	my ( $login, $web, $topic ) = @_;
	# TWiki init
	&TWiki::basicInitialize();
	&TWiki::Store::initialize();
	if ( $web && $topic ) {
	   # Initialize web name
	   $TWiki::webName = $web;
	   # Initialize topic name
	   $TWiki::topicName = $topic;
	}
	# Initialize TWiki userName var
	$TWiki::wikiUserName = &TWiki::userToWikiName( $login );
	$TWiki::userName = &TWiki::initializeRemoteUser( $login );
	# Access control init
	&TWiki::Access::initializeAccess();
	return $TWiki::userName;
}

# Put/Release Administrative Lock
sub setAdminLock {
  my ( $key, $doUnlock ) = @_;
  my ( $checkCode, $lockedKey, $lockedTime );
  # Retrieve login
  my $login = &getLogin( $key );
  return -2 if ( ! $login );
  # TWiki init
	&initialize( $login );
  # Admin Group ?
  return -1 if ( ! TWiki::Access::userIsInGroup( &TWiki::userToWikiName( $login ), $TWiki::superAdminGroup ) );
  # Check state wanted
  if ( ! $doUnlock ) {
    ( $checkCode, $lockedKey, $lockedTime ) = &TWiki::Contrib::TRefactorAddOn::AdminLock::doLock( $key );
    if ( ! $checkCode ) {
      &TWiki::Contrib::TRefactorAddOn::Trace::log( "Administrative lock put by $login ($key)" );
      return 1;
    }
  } else {
    # Unlock (with concurrence management)
    ( $checkCode, $lockedKey, $lockedTime ) = &TWiki::Contrib::TRefactorAddOn::AdminLock::doUnlock( $key );
    if ( ! $checkCode ) {
      &TWiki::Contrib::TRefactorAddOn::Trace::log( "Administrative lock released by $login ($key)" );
      return 1;
    }
  }
  return ( 0, &getLogin( $lockedKey ), $lockedTime );
};

1;