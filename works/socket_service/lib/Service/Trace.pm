package Service::Trace;

# Service Trace Module
# Author : Romain Raugi

use strict;

use vars qw($lock);

# Lock file
$lock = "$Service::trace_file.lock";

sub log {
  my ( $arg ) = @_;
  my $date = localtime(time());
  return if ( ! $Service::trace_mode );
  &Service::FLock::lock( $lock );
  open(FILE, ">>$Service::trace_file");
  print FILE "$date >> $arg\n";
  close(FILE);
  &Service::FLock::unlock( $lock );
}

1;