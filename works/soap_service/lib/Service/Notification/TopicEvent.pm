package Service::Notification::TopicEvent;

# Topic Event Object
# Author : Romain Raugi

if ( $Service::notifications ) {
  eval "use XML::Element;";
}

sub new
{
  my( $proto, $web, $name, $operation ) = @_;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless( $self, $class );
  $self->{'web'} = $web;
  $self->{'name'} = $name;
  $self->{'operation'} = $operation;
  return $self;
}

sub root {
  my ( $self ) = @_;
  my $root = XML::Element->new( 'topicEvent' );
  my $xml_message_web = XML::Element->new( 'web' );
  my $xml_message_name = XML::Element->new( 'name' );
  my $xml_message_operation = XML::Element->new( 'operation' );
  $xml_message_web->push_content( $self->{'web'} );
  $xml_message_name->push_content( $self->{'name'} );
  $xml_message_operation->push_content( $self->{'operation'} );
  $root->push_content( $xml_message_web );
  $root->push_content( $xml_message_name );
  $root->push_content( $xml_message_operation );
  return $root;
}

1;