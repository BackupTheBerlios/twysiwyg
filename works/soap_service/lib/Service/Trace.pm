package Service::Trace;

# Service Trace Module
# Author : Romain Raugi

use strict;

use vars qw($lock);

# Lock file
$lock = "$Service::trace_file.lock";

sub TRACE {
  my ( $arg ) = @_;
  my $date = localtime(time());
  return if ( ! $Service::trace_mode );
  &Service::FileLock::lock( $lock );
  open(FILE, ">>$Service::trace_file");
  print FILE "$date >> $arg\n";
  close(FILE);
  &Service::FileLock::unlock( $lock );
}

1;