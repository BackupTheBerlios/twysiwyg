package Service::Locks;

# Locks Associations Module
# Author : Romain Raugi

use strict;
use File::stat;

use vars qw($lock);

# Lock file
$lock = "$Service::locks_file.lock";

sub locks {
  my $locks_ref;
  my ( $line, $key, $saved_date, $filename, $effective_date, $failed );
  &Service::FileLock::lock( $lock );
  open(FILE, "<$Service::locks_file") or $failed = 1;
  if ( ! $failed ) {
    while( $line = <FILE> ) {
      ( $key, $saved_date, $filename ) = split/ /, $line, 3;
      chomp $filename;
      if ( $filename ne '' && -e $filename ) {
        my $st = stat($filename);
        if ( $st ) {
&Service::Trace::TRACE("LOAD : $filename");
          $effective_date = $st->mtime;
          # Load lock if dates are equals
          $locks_ref->{$key}{$filename} = $saved_date if ( $saved_date eq $effective_date );
        }
      }
    }
    close(FILE);
  }
  &Service::FileLock::unlock( $lock );
  return $locks_ref;
}

sub save {
  my $locks_ref = shift;
  my $failed;
  &Service::FileLock::lock( $lock );
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
  &Service::FileLock::unlock( $lock );
}

sub add {
  my ( $key, $web, $topic ) = @_;
&Service::Trace::TRACE("Locks Add Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
  my $filename = getLockFilename($web, $topic);
&Service::Trace::TRACE("Lock Filename : $filename");
  my $st = stat($filename);
  if ( $st ) {
    my $date = $st->mtime;
&Service::Trace::TRACE("Modified Time : $date");
    # Loading locks associations
    my $locks = locks();
    # Adding association
    $locks->{$key}{$filename} = $date;
    &save($locks);
&Service::Trace::TRACE("Add OK");
  }
}

sub remove {
  my ( $key, $web, $topic ) = @_;
&Service::Trace::TRACE("Locks Remove Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
  my $filename = getLockFilename($web, $topic);
&Service::Trace::TRACE("Lock Filename : $filename");
  # Loading locks associations
  my $locks = locks();
  # Removing association
  my $hash = $locks->{ $key };
  delete $hash->{$filename};
  &save($locks);
&Service::Trace::TRACE("Remove OK");
}

sub getLocks {
  # Retrieve locks put by a user
  my ( $key ) = @_;
&Service::Trace::TRACE("Locks GetLocks Procedure");
&Service::Trace::TRACE("Key : $key");
  # Loading locks associations
  my $locks = locks();
  my @values = ();
  for my $filename ( sort keys %{$locks->{ $key }} ) {
    push @values, $filename;
  }
&Service::Trace::TRACE("Locks : @values, Last idx : $#values");
  return @values;
}

sub hasLocked {
  my ( $key, $web, $topic ) = @_;
&Service::Trace::TRACE("Locks HasLocked Procedure");
&Service::Trace::TRACE("Key : $key");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
  my $filename =  getLockFilename($web, $topic);
&Service::Trace::TRACE("Lock Filename : $filename");
  # Loading locks associations
  my $locks = locks();
  my $hash = $locks->{ $key };
&Service::Trace::TRACE("Filenames : $hash");
  return exists $hash->{$filename};
}

sub getLockingUsers {
  my ( $web, $topic ) = @_;
&Service::Trace::TRACE("Locks GetLockingUsers Procedure");
&Service::Trace::TRACE("Web : $web");
&Service::Trace::TRACE("Topic : $topic");
  my $filename =  getLockFilename($web, $topic);
&Service::Trace::TRACE("Lock Filename : $filename");
  # Loading locks associations
  my $locks = locks();
  my @results = ();
  for my $key ( sort keys %$locks ) {
    for my $name ( sort keys %{$locks->{ $key }} ) {
      push @results, $key if ( $filename eq $name );
    }
  }
&Service::Trace::TRACE("Users : @results");
&Service::Trace::TRACE("Users Last idx : $#results");
  return @results;
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