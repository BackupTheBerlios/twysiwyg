package Service;

# Service Global Module & Requests Dispatcher
# Author : Romain Raugi

use strict;
use TWiki;

use Service::Connection;
use Service::Trace;
use Service::FLock;
use Service::Locks;
use Service::Topics;
use Service::AdminLock;
use Service::Refactoring;
use Service::Undo;

use vars qw($endpoint $key_range $timeout $max_connections $clients_file
            $locks_file $trace_file $trace_mode $jnlpDir $uploadDir $admin_lock_file
            $tarCmd $rmCmd $undoFile $snapshotFileName);

BEGIN {
	do "Service.cfg";
}

1;