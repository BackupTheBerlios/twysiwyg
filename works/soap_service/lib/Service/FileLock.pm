package Service::FileLock;

# FileLock Concurrence Management on service's data files
# Author : Romain Raugi

use strict;

# Lock a file with the lockfile passed in parameter
sub lock {
  my ( $lock ) = @_;
  my $inc = 0;
  # Random sleeping time
  my $rand = rand(1) + 0.01;
  # Test lock existence
  while (-e $lock) {
    if ($inc == $Service::max_filelock_tries) {
      # Deadlock case
      unlink($lock);
    }
    # Sleep (in milliseconds)
    select(undef,undef,undef,$rand);
    $inc++;
  }
  open(LOCK, ">$lock");
  my $date = time();
  print LOCK "$date\n";
  close(LOCK);
}

sub unlock {
  my ( $lock ) = @_;
  unlink($lock);
}

1;