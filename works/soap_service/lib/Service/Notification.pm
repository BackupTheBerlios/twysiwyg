package Service::Notification;

# Service's Notification Module
# Author : Romain Raugi

use IO::Socket;

if ( $Service::notifications ) {
  eval "use XML::Element;";
}

use vars qw($lock);

# Lock file
$lock = "$Service::contacts_file.lock";

sub contacts {
  my $contacts_ref;
  my ( $line, $key, $login, $ip, $port );
  &Service::FileLock::lock( $lock );
  # Read values and save them in hash
  open(FILE, "<$Service::contacts_file") or $failed = 1;
  if ( ! $failed ) {
    while($line = <FILE>) {
      ($key, $ip, $port) = split/ /, $line, 3;
      # Delete last separator
      chomp $port;
      # Retrieve login & check connected clients
      $login = &Service::Connection::getLogin( $key );
      if ( $login ) {
        $contacts_ref->{$key}{'LOGIN'} = $login;
        $contacts_ref->{$key}{'IP'} = $ip;
        $contacts_ref->{$key}{'PORT'} = $port;
      }
    }
    close(FILE);
  }
  &Service::FileLock::unlock( $lock );
  return $contacts_ref;
}

sub save {
  my $contacts_ref = shift;
  my ( $key, $ip, $port );
  &Service::FileLock::lock( $lock );
  # Save values in text file
  open(FILE, ">$Service::contacts_file") or $failed = 1;
  if ( ! $failed ) {
    for $key ( sort keys %$contacts_ref ) {
      $ip = $contacts_ref->{$key}{'IP'};
      $port = $contacts_ref->{$key}{'PORT'};
      print FILE "$key $ip $port\n";
    }
    close(FILE);
  }
  &Service::FileLock::unlock( $lock );
}

# Web Service
sub subscribe {
  my $object = shift;
  my ( $key, $port ) = @_;
  my $ip = $ENV{'REMOTE_ADDR'};
&Service::Trace::TRACE("Subscribe Procedure");
  if ( $Service::notifications ) {
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("IP : $ip");
&Service::Trace::TRACE("Port : $port");
    # Retrieve login
    my $login = &Service::Connection::getLogin($key);
&Service::Trace::TRACE("Login : $login");
    return Service::Conversions::soap_boolean('response', 0) if ( ! $login );
    # Retrieve contacts from data source
    my $contacts = contacts();
    # New user
    $contacts->{$key}{'IP'} = "$ip";
    $contacts->{$key}{'PORT'} = "$port";
    # Save
    &save($contacts);
    return Service::Conversions::soap_boolean('response', 1);
  } else {
    return Service::Conversions::soap_boolean('response', 0);
  }
}

# Web Service
sub removeSubscription {
  my $object = shift;
  my ( $key ) = @_;
  if ( $Service::notifications ) {
    # Retrieve contacts from data source
    my $contacts = contacts();
    if ( exists $contacts->{$key} ) {
      delete $contacts->{$key};
      # Save
      &save($contacts);
      return Service::Conversions::soap_boolean('response', 1);
    }
  }
  return Service::Conversions::soap_boolean('response', 0);
}

# Actualize an user's ip
sub actualize {
  my ( $key ) = @_;
  if ( $Service::notifications ) {
    # Retrieve contacts from data source
    my $contacts = contacts();
    if ( exists $contacts->{$key} ) {
      # Actualize user's ip (if he change)
      my $ip = $ENV{'REMOTE_ADDR'};
      $contacts->{$key}{'IP'} = "$ip";
      # Save
      &save($contacts);
    }
  }
}

# Send message to client
sub send {
  my ( $key, $type, $login, $description, $event ) = @_;
  my ( $ip, $port );
  if ( $Service::notifications ) {
    # Retrieve contacts from data source
    my $contacts = contacts();
    # Get user's ip & port
    if ( exists $contacts->{$key} ) {
      $ip = $contacts->{$key}{'IP'};
      $port = $contacts->{$key}{'PORT'};
    }
    # Send messages
    for $skey ( sort keys %$contacts ) {
      # Message not sent to event emitter
      if ( $skey ne $key ) {
        my $send_to_ip = $contacts->{$skey}{'IP'};
        my $send_to_port = $contacts->{$skey}{'PORT'};
&Service::Trace::TRACE("Sending Message to $skey : $send_to_ip:$send_to_port");
        my $sock = new IO::Socket::INET (
                                          PeerAddr => "$send_to_ip",
                                          PeerPort => "$send_to_port",
                                          Proto => 'tcp',
                                        );
        if ( $sock ) {
          print $sock &xml_message( $type, $login, $ip, $port, $description, $event );
          close($sock);
        }
      }
    }
  }
}

# Return XML Message
sub xml_message {
  my ( $type, $login, $ip, $port, $text, $event ) = @_;
  my $root = XML::Element->new( 'Message' );
  my $xml_message_type = XML::Element->new( 'type' );
  my $xml_message_issuer = XML::Element->new( 'issuer' );
  my $xml_message_issuer_login = XML::Element->new( 'login' );
  my $xml_message_issuer_address = undef;
  my $xml_message_text = XML::Element->new( 'text' );
  my $xml_message_event;
  # Send issuer address
  if ( $ip && $port ) {
&Service::Trace::TRACE("OK to send ip & port");
    $xml_message_issuer_address = XML::Element->new( 'address' );
    my $xml_message_issuer_address_ip = XML::Element->new( 'ip' );
    my $xml_message_issuer_address_port = XML::Element->new( 'port' );
    $xml_message_issuer_address_ip->push_content( $ip );
    $xml_message_issuer_address_port->push_content( int($port) );
    $xml_message_issuer_address->push_content( $xml_message_issuer_address_ip );
    $xml_message_issuer_address->push_content( $xml_message_issuer_address_port );
  }
  # Event
  $xml_message_event = XML::Element->new( 'event' ) if ( $event );
  $xml_message_event->push_content( $event->root() ) if ( $event );
  # Params
  $xml_message_type->push_content( int($type) );
  $xml_message_issuer_login->push_content( $login );
  $xml_message_issuer->push_content( $xml_message_issuer_login );
  $xml_message_issuer->push_content( $xml_message_issuer_address ) if ( $xml_message_issuer_address );
  $xml_message_text->push_content( $text );
  # Final Message
  $root->push_content( $xml_message_type );
  $root->push_content( $xml_message_issuer );
  $root->push_content( $xml_message_text );
  $root->push_content( $xml_message_event ) if ( $event );
  return $root->as_XML();
}

1;