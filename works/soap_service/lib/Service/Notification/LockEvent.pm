package Service::Notification::LockEvent;

# Lock Event Object
# Author : Romain Raugi

if ( $Service::notifications ) {
  eval "use XML::Element;";
}

sub new
{
  my( $proto, $locked, $lock ) = @_;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless( $self, $class );
  $self->{'locked'} = $locked;
  $self->{'lock'} = $lock;
  return $self;
}

sub root {
  my ( $self ) = @_;
  my $root = XML::Element->new( 'lockEvent' );
  my $xml_message_locked = XML::Element->new( 'locked' );
  my $xml_message_lock = XML::Element->new( 'lock' );
  $xml_message_locked->push_content( $self->{'locked'} );
  $xml_message_lock->push_content( $self->{'lock'} );
  $root->push_content( $xml_message_locked );
  $root->push_content( $xml_message_lock );
  return $root;
}

1;