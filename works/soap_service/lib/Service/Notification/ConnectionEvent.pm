package Service::Notification::ConnectionEvent;

# Connection Event Object
# Author : Romain Raugi

if ( $Service::notifications ) {
  eval "use XML::Element;";
}

sub new
{
  my( $proto, $connected ) = @_;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless( $self, $class );
  $self->{'connected'} = $connected;
  return $self;
}

sub root {
  my ( $self ) = @_;
  my $root = XML::Element->new( 'connectionEvent' );
  my $xml_message_connected = XML::Element->new( 'connected' );
  $xml_message_connected->push_content( $self->{'connected'} );
  $root->push_content( $xml_message_connected );
  return $root;
}

1;