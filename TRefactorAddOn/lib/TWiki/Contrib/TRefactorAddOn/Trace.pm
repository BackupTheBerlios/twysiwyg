# TWiki TRefactorAddOn Trace Module
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
# $Id: Trace.pm,v 1.1 2004/11/21 10:48:49 romano Exp $

package TWiki::Contrib::TRefactorAddOn::Trace;

use strict;

sub log {
  my ( $arg ) = @_;
  my $lock = $TWiki::Contrib::TRefactorAddOn::traceFile.".lock";
  my $date = localtime( time() );
  return if ( ! $TWiki::Contrib::TRefactorAddOn::traceMode );
  &TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
  open(FILE, ">>$TWiki::Contrib::TRefactorAddOn::traceFile");
  print FILE "$date >> $arg\n";
  close(FILE);
  &TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
}

1;