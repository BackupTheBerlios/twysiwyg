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

use vars qw($key_range $timeout $max_connections $clients_file
            $locks_file $trace_file $trace_mode $admin_lock_file
            );

BEGIN {
	do "Service.cfg";
}

1;