# TWiki TRefactorAddOn FLock Module
# FLock Concurrence Management on service's data files
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
# $Id: FLock.pm,v 1.1 2004/11/21 10:48:47 romano Exp $

package TWiki::Contrib::TRefactorAddOn::FLock;

use strict;

# Lock a file with the lockfile passed in parameter
sub lock {
  my ( $lock ) = @_;
  my $maxTries = 10;
  my $inc = 0;
  # Random sleeping time
  my $rand = rand(1) + 0.01;
  # Test lock existence
  while ( -e $lock ) {
    if ( $inc == $maxTries ) {
      # Deadlock case
      unlink( $lock );
    }
    # Sleep (in milliseconds)
    select( undef, undef, undef, $rand );
    $inc++;
  }
  open( LOCK, ">$lock" );
  close( LOCK );
}

sub unlock {
  my ( $lock ) = @_;
  unlink( $lock );
}

1;