# TWiki TRefactorAddOn Main Module
#
# TWiki TRefactorAddOn add-on for TWiki
# Copyright (C) 2004 Maxime Lamure, Mario Di Miceli, Damien Mandrioli & Romain Raugi
# 
# Based on parts of TWiki.
# Copyright (C) 1999-2004 Peter Thoeny, peter@thoeny.com
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
# $Id: TRefactorAddOn.pm,v 1.1 2004/11/21 10:48:46 romano Exp $

package TWiki::Contrib::TRefactorAddOn;

use strict;
use TWiki;

use TWiki::Contrib::TRefactorAddOn::Connection;
use TWiki::Contrib::TRefactorAddOn::Trace;
use TWiki::Contrib::TRefactorAddOn::FLock;
use TWiki::Contrib::TRefactorAddOn::Locks;
use TWiki::Contrib::TRefactorAddOn::Topics;
use TWiki::Contrib::TRefactorAddOn::AdminLock;
use TWiki::Contrib::TRefactorAddOn::Refactoring;

use vars qw($keyRange $timeout $maxConnections $clientsFile
            $locksFile $traceFile $traceMode $adminLockFile
            $VERSION);

BEGIN {
  $VERSION = 1.0.0;
	do "$TWiki::dataDir/TRefactorAddOn.cfg";
}

1;