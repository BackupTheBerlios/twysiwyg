package Service::AdminLock;

# Administrative Locks Management
# Author : Romain Raugi

use strict;

# Retrieve locktime and lockuser in administrative lock
sub checkAdminLock {
  # Let procedure unlock ?
  my ( $dontUnlock ) = @_;
  my $lock = $Service::adminLockFile.".lock";
  my ( $lockedKey, $lockedTime );
  my $failed;
  # Open it and retrieve values
  &Service::FLock::lock( $lock );
  open( FILE, "<$Service::adminLockFile" ) or $failed = 1;
  if ( $failed ) {
    &Service::FLock::unlock( $lock ) if ( ! $dontUnlock );
    return ( 0, undef, undef );
  }
  my $content = '';
  while ( my $line = <FILE> ) {
    $content .= $line;
  }
  ( $lockedKey, $lockedTime ) = split/\n/, $content;
  close( FILE );
  &Service::FLock::unlock( $lock ) if ( ! $dontUnlock );
  return ( 1, $lockedKey, $lockedTime );
}

# Create (or refresh) administrative lock
sub doLock {
  my ( $key ) = @_;
  my $lock = $Service::adminLockFile.".lock";
  my $date = time();
  my $failed = 1;
  my ( $checkCode, $lockedKey, $lockedTime ) = &checkAdminLock( 1 );
  if ( ( ! $checkCode || ! $lockedKey || ! $lockedTime  ) ||
      ( ( $lockedKey eq $key ) || ( ( $date - $lockedTime ) >= $Service::timeout ) ) ) {
      open( FILE, ">$Service::adminLockFile" ) or $failed = 1;
      print FILE "$key\n$date";
      close( FILE );
      $failed = 0;
  }
  &Service::FLock::unlock( $lock );
  return ( $failed, $lockedKey, $lockedTime );
}

# Unlock admin lock
sub doUnlock {
  my ( $key ) = @_;
  my $lock = $Service::adminLockFile.".lock";
  my $failed = 1;
  my ( $checkCode, $lockedKey, $lockedTime ) = checkAdminLock( 1 );
  if ( $checkCode && ( $lockedKey eq $key ) ) {
    # Delete file
    unlink( $Service::adminLockFile );
    $failed = 0;
  }
  &Service::FLock::unlock( $lock );
  return ( $failed, $lockedKey, $lockedTime );
}

1;