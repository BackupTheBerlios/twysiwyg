package Service::Notification::RefactoringEvent;

# Refactoring Event Object
# Author : Romain Raugi

if ( $Service::notifications ) {
  eval "use XML::Element;";
}

sub new
{
  my( $proto, $oldWeb, $oldName, $oldParent, $newWeb, $newName, $newParent, $operation ) = @_;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless( $self, $class );
  $self->{'oldWeb'} = $oldWeb;
  $self->{'oldName'} = $oldName;
  $self->{'oldParent'} = $oldParent;
  $self->{'newWeb'} = $newWeb;
  $self->{'newName'} = $newName;
  $self->{'newParent'} = $newParent;
  $self->{'operation'} = $operation;
  return $self;
}

sub root {
  my ( $self ) = @_;
  my $root = XML::Element->new( 'refactoringEvent' );
  my $xml_message_oldweb = XML::Element->new( 'oldWeb' );
  my $xml_message_oldname = XML::Element->new( 'oldName' );
  my $xml_message_oldparent = XML::Element->new( 'oldParent' );
  my $xml_message_newweb = XML::Element->new( 'newWeb' );
  my $xml_message_newname = XML::Element->new( 'newName' );
  my $xml_message_newparent = XML::Element->new( 'newParent' );
  my $xml_message_operation = XML::Element->new( 'operation' );
  $xml_message_oldweb->push_content( $self->{'oldWeb'} );
  $xml_message_oldname->push_content( $self->{'oldName'} );
  $xml_message_oldparent->push_content( $self->{'oldParent'} );
  $xml_message_newweb->push_content( $self->{'newWeb'} );
  $xml_message_newname->push_content( $self->{'newName'} );
  $xml_message_newparent->push_content( $self->{'newParent'} );
  $xml_message_operation->push_content( $self->{'operation'} );
  $root->push_content( $xml_message_oldweb );
  $root->push_content( $xml_message_oldname );
  $root->push_content( $xml_message_oldparent );
  $root->push_content( $xml_message_newname );
  $root->push_content( $xml_message_newweb );
  $root->push_content( $xml_message_newparent );
  $root->push_content( $xml_message_operation );
  return $root;
}

1;