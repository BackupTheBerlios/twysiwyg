package Service::AdminLock;

# Administrative Locks Management
# Author : Romain Raugi

use strict;

use vars qw($lock);

# Admin lock Filename Lock
$lock = "$Service::admin_lock_file.lock";

# Retrieve locktime and lockuser in administrative lock
sub checkAdminLock {
  # Let procedure unlock ?
  my ( $dontUnlock ) = @_;
&Service::Trace::TRACE("CheckAdminLock Procedure");
&Service::Trace::TRACE("DontUnlock : $dontUnlock");
  my ( $lockedKey, $lockedTime );
  my $failed;
  # Check only if service is configured for
  return ( 0, undef, undef ) if ( ! $Service::admin_lock );
  # Open it and retrieve values
  &Service::FileLock::lock($lock);
  open(FILE, "<$Service::admin_lock_file") or $failed = 1;
  if ( $failed ) {
    &Service::FileLock::unlock($lock) if ( ! $dontUnlock );
    return ( 0, undef, undef );
  }
  my $content = '';
  while ( my $line = <FILE> ) {
    $content .= $line;
  }
  ( $lockedKey, $lockedTime ) = split/\n/, $content;
&Service::Trace::TRACE("LockedKey : $lockedKey");
&Service::Trace::TRACE("LockedTime : $lockedTime");
  close(FILE);
  &Service::FileLock::unlock($lock) if ( ! $dontUnlock );
  return ( 1, $lockedKey, $lockedTime );
}

# Create (or refresh) administrative lock
sub doLock {
  my ( $key ) = @_;
  my $date = time();
  my $failed = 1;
&Service::Trace::TRACE("DoLock Procedure");
&Service::Trace::TRACE("Key : $key");
  my ( $checkCode, $lockedKey, $lockedTime ) = &checkAdminLock( 1 );
  if ( ( ! $checkCode || ! $lockedKey || ! $lockedTime  ) ||
      ( ( $lockedKey eq $key ) || ( ( $date - $lockedTime ) >= $Service::timeout ) ) ) {
&Service::Trace::TRACE("Ok to create lock");
      open(FILE, ">$Service::admin_lock_file") or $failed = 1;
      print FILE "$key\n$date";
      close(FILE);
      $failed = 0;
  }
  &Service::FileLock::unlock($lock);
  return $failed;
}

# Unlock admin lock
sub doUnlock {
  my ( $key ) = @_;
  my $failed = 1;
&Service::Trace::TRACE("DoUnlock Procedure");
&Service::Trace::TRACE("Key : $key");
  my ( $checkCode, $lockedKey, $lockedTime ) = checkAdminLock( 1 );
&Service::Trace::TRACE("checkCode : $checkCode");
&Service::Trace::TRACE("lockedKey : $lockedKey");
&Service::Trace::TRACE("lockedTime : $lockedTime");
  if ( $checkCode && ( $lockedKey eq $key ) ) {
&Service::Trace::TRACE("Ok to unlock");
    # Delete file
    unlink($Service::admin_lock_file);
    $failed = 0;
&Service::Trace::TRACE("Unlock done");
  }
  &Service::FileLock::unlock($lock);
  return $failed;
}

1;