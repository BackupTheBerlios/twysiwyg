# TWiki TRefactorAddOn Locks Module
# Locks Associations Module
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
# $Id: Locks.pm,v 1.1 2004/11/21 10:48:47 romano Exp $

package TWiki::Contrib::TRefactorAddOn::Locks;

use strict;
use File::stat;

sub load {
	my $locks_ref;
	my $lock = $TWiki::Contrib::TRefactorAddOn::locksFile.".lock";
	my ( $line, $key, $saved_date, $filename, $effective_date, $failed );
	&TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
	open( FILE, "<$TWiki::Contrib::TRefactorAddOn::locksFile" ) or $failed = 1;
	if ( ! $failed ) {
 		while( $line = <FILE> ) {
			( $key, $saved_date, $filename ) = split/ /, $line, 3;
			chomp $filename;
			if ( $filename ne '' && -e $filename ) {
				my $st = stat( $filename );
				if ( $st ) {
					$effective_date = $st->mtime;
					# Load lock if dates are equals
					$locks_ref->{$key}{$filename} = $saved_date if ( $saved_date eq $effective_date );
				}
			}
		}
		close(FILE);
	}
	&TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
	return $locks_ref;
}

sub save {
	my $locks_ref = shift;
	my $lock = $TWiki::Contrib::TRefactorAddOn::locksFile.".lock";
	my $failed;
	&TWiki::Contrib::TRefactorAddOn::FLock::lock( $lock );
	# Save values in text file
  open( FILE, ">$Service::locksFile" ) or $failed = 1;
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
	&TWiki::Contrib::TRefactorAddOn::FLock::unlock( $lock );
}

sub add {
	my ( $key, $web, $topic ) = @_;
	my $filename = &getLockFilename( $web, $topic );
	my $st = stat( $filename );
	if ( $st ) {
		my $date = $st->mtime;
		# Loading locks associations
		my $locks = load();
		# Adding association
		$locks->{$key}{$filename} = $date;
		&save( $locks );
	}
}

sub remove {
	my ( $key, $web, $topic ) = @_;
	my $filename = &getLockFilename( $web, $topic );
	# Loading locks associations
	my $locks = load();
	# Removing association
	my $hash = $locks->{$key};
	delete $hash->{$filename};
	&save( $locks );
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
	my $filename =  &getLockFilename($web, $topic);
	# Loading locks associations
	my $locks = load();
	my @results = ();
	for my $key ( sort keys %$locks ) {
		for my $name ( sort keys %{$locks->{ $key }} ) {
			push @results, $key if ( $filename eq $name );
		}
	}
	# Return the last if there are several users
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