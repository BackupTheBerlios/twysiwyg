package Service::Connection;

# Service Connection Module
# Author : Romain Raugi, based on Peter Thoeny's works for TWiki

use strict;

use vars qw($lock);

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

if ( $TWiki::OS eq "WINDOWS" ) {
	require MIME::Base64;
	require Digest::SHA1;
}

# Lock file
$lock = "$Service::clients_file.lock";

sub load {
	my $clients_ref;
	my ( $line, $key, $usage, $login, $cnx, $echo, $failed );
	&Service::FLock::lock( $lock );
	# Read values and save them in hash
	open(FILE, "<$Service::clients_file") or $failed = 1;
	if ( ! $failed ) {
    	my $date = time();
    	while($line = <FILE>) {
      		($key, $usage, $login, $cnx, $echo) = split/ /, $line, 5;
      		# Delete last separator
      		chomp $echo;
      		# Check Timeouts
      		if (($date - $echo) < $Service::timeout) {
        		$clients_ref->{$key}{'LOGIN'} = $login;
        		$clients_ref->{$key}{'USAGE'} = $usage;
        		$clients_ref->{$key}{'CNX'} = $cnx;
        		$clients_ref->{$key}{'ECHO'} = $echo;
      		}
      		else {
        		# Unlock all put locks
				&locks( $key, $login, 1 );
      		}
    	}
    	close(FILE);
  	}
  	&Service::FLock::unlock( $lock );
  	return $clients_ref;
}

sub save {
	my $clients_ref = shift;
	my ( $key, $usage, $login, $cnx, $echo, $failed );
	&Service::FLock::lock( $lock );
	# Save values in text file
	open(FILE, ">$Service::clients_file") or $failed = 1;
 	if ( ! $failed ) {
		for $key ( sort keys %$clients_ref ) {
      		$usage = $clients_ref->{$key}{'USAGE'};
      		$login = $clients_ref->{$key}{'LOGIN'};
      		$cnx = $clients_ref->{$key}{'CNX'};
      		$echo = $clients_ref->{$key}{'ECHO'};
      		print FILE "$key $usage $login $cnx $echo\n";
   		}
    	close(FILE);
  	}
  	&Service::FLock::unlock( $lock );
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
	&Service::Trace::log( "Connection attempt from $login for $usage usage" );
	# Check Login & Pass
	if ( $login !~ /^guest$/i ) {
		if ( ! &check( $login, $pass ) ) {
			&Service::Trace::log( "Authentication of $login failed" );
			return -3;
		}
	}
	&Service::Trace::log("Authentication from $login OK");
	# Retrieve clients from data source
	my $clients = load();
	# No possible connections now (not enough keys) : extreme case
	my @keys = keys %$clients;
	my $max_connections_reached = ( $#keys == ( $Service::max_connections - 1 ) );
	if ( $max_connections_reached ) {
		&Service::Trace::log("Connection failed, maximum number of connections reached");
		return -2;
	}
	# Generate non-existing key
   	my $key = int( rand( $Service::key_range ) ) + 1;
   	while ( exists $$clients{$key} ) {
		$key = int( rand( $Service::key_range ) ) + 1;
	}
	# New user
	$clients->{$key}{'LOGIN'} = "$login";
	$clients->{$key}{'USAGE'} = "$usage";
	$clients->{$key}{'CNX'} = "$echo";
	$clients->{$key}{'ECHO'} = "$echo";
	# Save
	&save( $clients );
	&Service::Trace::log( "Connection established by $login, key : $key" );
	return ( $key, $Service::timeout );
}

sub disconnect {
	my ( $key ) = @_;
	&Service::Trace::log( "Disconnection attempt from $key" );
	# Retrieve clients from data source
	my $clients = load();
	if (exists $clients->{$key}) {
		# Get login
		my $login = $clients->{$key}{'LOGIN'};
		# Delete entry
		delete $clients->{$key};
		&save($clients);
		# Unlock all put locks
		&locks( $key, $login, 1 );
		&Service::Trace::log( "Disconnection from $key OK" );
		return 1;
	}
	&Service::Trace::log( "Disconnection from $key failed" );
	return 0;
}

sub ping {
	my ( $key ) = @_;
	&Service::Trace::log( "Ping from $key" );
	# Retrieve clients from data source
	my $clients = load();
	if (exists $clients->{$key}) {
		my $login = $clients->{$key}{'LOGIN'};
		my $echo = time();
		$clients->{$key}{'ECHO'} = "$echo";
		&save($clients);
		# Actualize all put locks
		&locks( $key, $login );
		&Service::Trace::log( "Ping from $key OK" );
		return 1;
	}
	&Service::Trace::log( "Ping from $key failed" );
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
	if (exists $clients->{$key}) {
		return $clients->{$key}{'LOGIN'};
	}
	return undef;
}

# Authentication
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
	my @locks = &Service::Locks::getLocks( $key );
	foreach my $filename ( @locks ) {
		my ( $web, $topic ) = &Service::Locks::getTopicLocation( $filename );
		# Initialize user
		&initialize( $login, $web, $topic );
		if ( $doUnlock ) {
			# Remove lock and association (implicit)
			&TWiki::Store::lockTopicNew( $web, $topic, 1 );
		} else {
			# Put TWiki lock (to actualize)
			&TWiki::Store::lockTopicNew( $web, $topic );
			# Actualize locks
			&Service::Locks::add( $key, $web, $topic );
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
	# Access control init
	&TWiki::Access::initializeAccess();
	# Initialize web name
	$TWiki::webName = $web;
	# Initialize topic name
	$TWiki::topicName = $topic;
	# Initialize TWiki userName var
	$TWiki::userName = &TWiki::Plugins::initializeUser( $login );
	return $TWiki::userName;
}

1;