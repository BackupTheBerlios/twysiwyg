package Service::Locks;

# Locks Associations Module
# Author : Romain Raugi

use strict;
use File::stat;

use vars qw($lock);

# Lock file
$lock = "$Service::locks_file.lock";

sub load {
	my $locks_ref;
	my ( $line, $key, $saved_date, $filename, $effective_date, $failed );
	&Service::FLock::lock( $lock );
	open(FILE, "<$Service::locks_file") or $failed = 1;
	if ( ! $failed ) {
 		while( $line = <FILE> ) {
			( $key, $saved_date, $filename ) = split/ /, $line, 3;
			chomp $filename;
			if ( $filename ne '' && -e $filename ) {
				my $st = stat($filename);
				if ( $st ) {
					$effective_date = $st->mtime;
					# Load lock if dates are equals
					$locks_ref->{$key}{$filename} = $saved_date if ( $saved_date eq $effective_date );
				}
			}
		}
		close(FILE);
	}
	&Service::FLock::unlock( $lock );
	return $locks_ref;
}

sub save {
	my $locks_ref = shift;
	my $failed;
	&Service::FLock::lock( $lock );
	# Save values in text file
	open(FILE, ">$Service::locks_file") or $failed = 1;
	if ( ! $failed ) {
		for my $key ( sort keys %$locks_ref ) {
			my $filenames = $locks_ref->{ $key };
			for my $filename ( keys %$filenames ) {
				my $date = $filenames->{$filename};
				print FILE "$key $date $filename\n";
			}
		}
		close(FILE);
	}
	&Service::FLock::unlock( $lock );
}

sub add {
	my ( $key, $web, $topic ) = @_;
	my $filename = getLockFilename($web, $topic);
	my $st = stat($filename);
	if ( $st ) {
		my $date = $st->mtime;
		# Loading locks associations
		my $locks = load();
		# Adding association
		$locks->{$key}{$filename} = $date;
		&save($locks);
	}
}

sub remove {
	my ( $key, $web, $topic ) = @_;
	my $filename = getLockFilename($web, $topic);
	# Loading locks associations
	my $locks = load();
	# Removing association
	my $hash = $locks->{ $key };
	delete $hash->{$filename};
	&save($locks);
}

sub getLocks {
	# Retrieve locks put by a user
	my ( $key ) = @_;
	# Loading locks associations
	my $locks = load();
	my @values = ();
	for my $filename ( sort keys %{$locks->{ $key }} ) {
		push @values, $filename;
	}
	return @values;
}

sub getLockingUser {
	my ( $web, $topic ) = @_;
	my $filename =  getLockFilename($web, $topic);
	# Loading locks associations
	my $locks = load();
	my @results = ();
	for my $key ( sort keys %$locks ) {
		for my $name ( sort keys %{$locks->{ $key }} ) {
			push @results, $key if ( $filename eq $name );
		}
	}
	return $results[$#results];
}

sub getLockFilename {
	my ( $web, $topic ) = @_;
	return $TWiki::dataDir."/$web/$topic.lock";
}

sub getTopicLocation {
	my ( $filename ) = @_;
	my ( $web, $topic );
	# Retrieve location from filename
	$filename =~ s/$TWiki::dataDir\/?//;
	if ( $filename =~ /(.*)[\/](.*)/ ) {
		$web = $1;
		$topic = $2;
		$topic =~ s/\.lock//;
	}
	return ( $web, $topic );
}

1;