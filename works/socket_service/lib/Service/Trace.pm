package Service::Trace;

# Service Trace Module
# Author : Romain Raugi

use strict;

sub log {
  my ( $arg ) = @_;
  my $lock = $Service::traceFile.".lock";
  my $date = localtime( time() );
  return if ( ! $Service::traceMode );
  &Service::FLock::lock( $lock );
  open(FILE, ">>$Service::traceFile");
  print FILE "$date >> $arg\n";
  close(FILE);
  &Service::FLock::unlock( $lock );
}

1;