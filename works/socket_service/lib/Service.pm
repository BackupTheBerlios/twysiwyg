package Service;

# Service Global Module

use strict;
use TWiki;

use Service::Connection;
use Service::Trace;
use Service::FLock;
use Service::Locks;
use Service::Topics;
use Service::AdminLock;
use Service::Refactoring;

use vars qw($keyRange $timeout $maxConnections $clientsFile
            $locksFile $traceFile $traceMode $adminLockFile
            );

BEGIN {
	do "Service.cfg";
}

1;