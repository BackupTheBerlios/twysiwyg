package Service::Trace;

# Service Trace Module
# Author : Romain Raugi

use strict;

use vars qw( $lock );

# Lock file
$lock = "$Service::traceFile.lock";

sub log {
  my ( $arg ) = @_;
  my $date = localtime( time() );
  return if ( ! $Service::traceMode );
  &Service::FLock::lock( $lock );
  open(FILE, ">>$Service::traceFile");
  print FILE "$date >> $arg\n";
  close(FILE);
  &Service::FLock::unlock( $lock );
}

1;