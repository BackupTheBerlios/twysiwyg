package Service::Connection;

# Service Connection Module
# Author : Romain Raugi, based on Peter Thoeny's works for TWiki

use strict;

use vars qw($lock);

eval "use TWiki::Store::$TWiki::storeTopicImpl;";

if( $TWiki::OS eq "WINDOWS" ) {
  require MIME::Base64;
  require Digest::SHA1;
}

# Lock file
$lock = "$Service::clients_file.lock";

sub clients {
  my $clients_ref;
  my ( $line, $key, $usage, $login, $cnx, $echo, $failed );
  &Service::FileLock::lock( $lock );
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
        # Unlock admin lock
        &Service::AdminLock::doUnlock( $key );
      }
    }
    close(FILE);
  }
  &Service::FileLock::unlock( $lock );
  return $clients_ref;
}

sub save {
  my $clients_ref = shift;
  my ( $key, $usage, $login, $cnx, $echo, $failed );
  &Service::FileLock::lock( $lock );
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
  &Service::FileLock::unlock( $lock );
}

# Web Service
sub connect {
   my $object = shift;
   my( $usage, $login, $pass ) = @_;
&Service::Trace::TRACE("Connection Procedure");
&Service::Trace::TRACE("Usage : $usage");
&Service::Trace::TRACE("Login : $login");
   # Current date
   my $echo = time();
   # Check spaces
   $usage =~ s/[ \t\n]+//;
&Service::Trace::TRACE("Usage : $usage");
   $login =~ s/[ \t\n]+//;
&Service::Trace::TRACE("Login a.t. : $login");
   # Check if login is not empty
   return undef if ($login eq "");
   # Check usage if not empty
   $usage = "not_specified" if ($usage eq "");
&Service::Trace::TRACE("Usage a.t. : $usage");
   # Check Login & Pass
   if ($login ne "guest") {
      return undef if ( ! &check( $login, $pass ) );
   }
   # Retrieve clients from data source
   my $clients = clients();
   # No possible connections now (not enough keys) : extreme case
   my @keys = keys %$clients;
&Service::Trace::TRACE("Keys Last Idx : $#keys");
   return undef if ($#keys == ($Service::max_connections - 1));
&Service::Trace::TRACE("Maximum number of connections not reached");
   # Generate non-existing key
   my $key = int(rand($Service::key_range)) + 1;
   while (exists $$clients{$key}) {
     $key = int(rand($Service::key_range)) + 1;
   }
&Service::Trace::TRACE("Key : $key");
   # New user
   $clients->{$key}{'LOGIN'} = "$login";
   $clients->{$key}{'USAGE'} = "$usage";
   $clients->{$key}{'CNX'} = "$echo";
   $clients->{$key}{'ECHO'} = "$echo";
   # Save
   &save($clients);
&Service::Trace::TRACE("Connection Add Client, timeout = $Service::timeout");
   # Notify event
   if ( $Service::notifications ) {
     my $event = Service::Notification::ConnectionEvent->new( 1 );
     &Service::Notification::send( $key, 1, "$login", "$login logged on service", $event );
   }
   return Service::Conversions::soap_connection_info('info', $key, $Service::timeout, $Service::subwebs, $Service::admin_lock, $Service::locks_refresh, $Service::allow_complete_remove);
}

# Web Service
sub disconnect {
   my $object = shift;
   my ( $key ) = @_;
&Service::Trace::TRACE("Disconnection Procedure");
&Service::Trace::TRACE("Key : $key");
   # Retrieve clients from data source
   my $clients = clients();
   if (exists $clients->{$key}) {
&Service::Trace::TRACE("Client $key exists");
     # Get login
     my $login = $clients->{$key}{'LOGIN'};
&Service::Trace::TRACE("Client Login : $login");
     # Delete entry
     delete $clients->{$key};
     &save($clients);
     # Unlock all put locks
     &locks( $key, $login, 1 );
     # Unlock admin lock
     &Service::AdminLock::doUnlock( $key );
&Service::Trace::TRACE("Disconnection OK");
     # Notify event
     if ( $Service::notifications ) {
       my $event = Service::Notification::ConnectionEvent->new( 0 );
       &Service::Notification::send( $key, 1, "$login", "$login logged off service", $event );
     }
     return Service::Conversions::soap_boolean('response', 1);
   }
   return Service::Conversions::soap_boolean('response', 0);
}

# Web Service
sub getUsers {
   my $object = shift;
   # Retrieve clients from data source
   my $clients = clients();
   my ( $key, $usage, $login, $cnx );
   my @values = ();
   for $key ( sort keys %$clients ) {
     $usage = $clients->{$key}{'USAGE'};
     $login = $clients->{$key}{'LOGIN'};
     $cnx = localtime($clients->{$key}{'CNX'});
     push @values, Service::Conversions::soap_user('user', $usage, $login, $cnx);
   }
   return Service::Conversions::soap_array('users', @values);
}

# Web Service
sub ping {
   my $object = shift;
   my ( $key ) = @_;
&Service::Trace::TRACE("Connection Ping Procedure");
&Service::Trace::TRACE("Key : $key");
   # Retrieve clients from data source
   my $clients = clients();
   if (exists $clients->{$key}) {
&Service::Trace::TRACE("Client $key exists");
     my $login = $clients->{$key}{'LOGIN'};
&Service::Trace::TRACE("Client Login : $login");
     my $echo = time();
     $clients->{$key}{'ECHO'} = "$echo";
     &save($clients);
     # Actualize all put locks
     &locks( $key, $login ) if ( $Service::locks_refresh );
     # Lock admin lock if already locked
     if ( $Service::locks_refresh ) {
       my ( $checkCode, $lockedKey, $lockedTime ) = &Service::AdminLock::checkAdminLock();
       &Service::AdminLock::doLock( $key ) if ( $checkCode && ( $lockedKey eq $key ) && ( ( $echo - $lockedTime ) < $Service::timeout ) );
     }
     # Actualize IP for notification
     &Service::Notification::actualize( $key );
&Service::Trace::TRACE("Ping OK");
     return Service::Conversions::soap_boolean('response', 1);
   }
   return Service::Conversions::soap_boolean('response', 0);
}

# Web Service
sub setAdminLock {
  my $object = shift;
  my ( $key, $doLock ) = @_;
&Service::Trace::TRACE("SetAdminLock");
&Service::Trace::TRACE("AdministrativeLock : $Service::admin_lock");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Lock : $doLock");
  my ( $checkCode, $lockedKey, $lockedTime );
  my $failed = 1;
  # Retrieve login
  my $login = getLogin($key);
&Service::Trace::TRACE("Login : $login");
  return Service::Conversions::soap_boolean('response', 0) if ( ! $login );
  # Admin Group ?
  return Service::Conversions::soap_boolean('response', 0) if ( $Service::super_admin_lock
     && ! &TWiki::Access::userIsInGroup( &TWiki::userToWikiName( $login ), $TWiki::superAdminGroup ) );
  # Check state wanted
  if ( $doLock ) {
    $failed = &Service::AdminLock::doLock( $key );
&Service::Trace::TRACE("Failed code : $failed");
    # Notify event
    if ( $Service::notifications ) {
      my $event = Service::Notification::LockEvent->new( 1, "Administrative Lock" );
      &Service::Notification::send( $key, 2, "$login", "$login put an administrative lock", $event );
    }
    return Service::Conversions::soap_boolean('response', 1) if ( ! $failed );
  } else {
    # Unlock (with concurrence management)
    $failed = &Service::AdminLock::doUnlock( $key );
&Service::Trace::TRACE("Failed code : $failed");
    # Notify event
    if ( $Service::notifications ) {
      my $event = Service::Notification::LockEvent->new( 0, "Administrative Lock" );
      &Service::Notification::send( $key, 2, "$login", "$login removed his administrative lock", $event );
    }
    return Service::Conversions::soap_boolean('response', 1) if ( ! $failed );
  }
  return Service::Conversions::soap_boolean('response', 0);
};

sub getLogin() {
   my ( $key ) = @_;
&Service::Trace::TRACE("Connection GetLogin Procedure");
&Service::Trace::TRACE("Key : $key");
   # Retrieve clients from data source
   my $clients = clients();
   if (exists $clients->{$key}) {
&Service::Trace::TRACE("Client $key exists");
&Service::Trace::TRACE("Client login : ".$clients->{$key}{'LOGIN'});
     return $clients->{$key}{'LOGIN'};
   }
   return undef;
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

sub locks {
  # Actualize or delete put locks (by a specific user)
  my (  $key, $login, $doUnlock ) = @_;
&Service::Trace::TRACE("Connection Locks Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Login : $login");
&Service::Trace::TRACE("DoUnlock : $doUnlock");
  my @locks = &Service::Locks::getLocks( $key );
&Service::Trace::TRACE("Locks : @locks");
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

# Authentication
sub check {
  my ( $login, $pass ) = @_;
  # Reading passwords file
  my $text = &TWiki::Store::readFile( $TWiki::htpasswdFilename );
&Service::Trace::TRACE("Check Procedure");
&Service::Trace::TRACE("Login : $login");
  if( $text =~ /$login\:(\S+)/ ) {
    my $oldcrypt = $1;
    my $pwd;
    # Compare crypted passwords
    if ( $TWiki::OS eq "WINDOWS" ) {
      $pwd = '{SHA}' . MIME::Base64::encode_base64( Digest::SHA1::sha1( $pass ) );
      # strip whitespace at end of line
      $pwd =~ /(.*)$/ ;
      $pwd = $1;
    } else {
      my $salt = substr( $oldcrypt, 0, 2 );
      $pwd = crypt( $pass, $salt );
    }
    return ($pwd eq $oldcrypt);
  }
  return 0;
}

1;