# TWiki TRefactorAddOn Administrative Lock Module
# 
# TWiki TRefactorAddOn add-on for TWiki
# Copyright (C) 2004 Maxime Lamure, Mario Di Miceli, Damien Mandrioli & Romain Raugi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# $Id: AdminLock.pm,v 1.1 2004/11/21 10:48:46 romano Exp $

package TWiki::Contrib::TRefactorAddOn::AdminLock;

use strict;

# Retrieve locktime and lockuser in administrative lock
sub checkAdminLock {
  # Let procedure unlock ?
  my ( $dontUnlock ) = @_;
  my $lock = $TWiki::Contrib::TRefactorAddOn::adminLockFile.".lock";
  my ( $lockedKey, $lockedTime );
  my $failed;
  # Open it and retrieve values
  &TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
  open( FILE, "<$TWiki::Contrib::TRefactorAddOn::adminLockFile" ) or $failed = 1;
  if ( $failed ) {
    &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock ) if ( ! $dontUnlock );
    return ( 0, undef, undef );
  }
  my $content = '';
  while ( my $line = <FILE> ) {
    $content .= $line;
  }
  ( $lockedKey, $lockedTime ) = split/\n/, $content;
  close( FILE );
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock ) if ( ! $dontUnlock );
  return ( 1, $lockedKey, $lockedTime );
}

# Create (or refresh) administrative lock
sub doLock {
  my ( $key ) = @_;
  my $lock = $TWiki::Contrib::TRefactorAddOn::adminLockFile.".lock";
  my $date = time();
  my $failed = 1;
  my ( $checkCode, $lockedKey, $lockedTime ) = &checkAdminLock( 1 );
  if ( ( ! $checkCode || ! $lockedKey || ! $lockedTime  ) ||
      ( ( $lockedKey eq $key ) || ( ( $date - $lockedTime ) >= $TWiki::Contrib::TRefactorAddOn::timeout ) ) ) {
      open( FILE, ">$TWiki::Contrib::TRefactorAddOn::adminLockFile" ) or $failed = 1;
      print FILE "$key\n$date";
      close( FILE );
      $failed = 0;
  }
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
  return ( $failed, $lockedKey, $lockedTime );
}

# Unlock admin lock
sub doUnlock {
  my ( $key ) = @_;
  my $lock = $TWiki::Contrib::TRefactorAddOn::adminLockFile.".lock";
  my $failed = 1;
  my ( $checkCode, $lockedKey, $lockedTime ) = checkAdminLock( 1 );
  if ( $checkCode && ( $lockedKey eq $key ) ) {
    # Delete file
    unlink( $TWiki::Contrib::TRefactorAddOn::adminLockFile );
    $failed = 0;
  }
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
  return ( $failed, $lockedKey, $lockedTime );
}

1;