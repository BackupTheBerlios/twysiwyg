#!/usr/bin/perl -w
#
# Example build class. Copy this file to the equivalent place in your
# plugin or contrib and edit.
#
# Read the comments at the top of lib/TWiki/Contrib/Build.pm for
# details of how the build process works, and what files you
# have to provide and where.
#
# Requires the environment variable TWIKI_LIBS (a colon-separated path
# list) to be set to point at the build system and any required dependencies.
# Usage: ./build.pl [-n] [-v] [target]
# where [target] is the optional build target (build, test,
# install, release, uninstall), test is the default.`
# Two command-line options are supported:
# -n Don't actually do anything, just print commands
# -v Be verbose
#

# Standard preamble
BEGIN {
  foreach my $pc (split(/:/, $ENV{TWIKI_LIBS})) {
    unshift @INC, $pc;
  }
}

use TWiki::Contrib::Build;

# Declare our build package
{ package TRefactorAddOnBuild;

  @TRefactorAddOnBuild::ISA = ( "TWiki::Contrib::Build" );

  sub new {
    my $class = shift;
    return bless( $class->SUPER::new( "TRefactorAddOn" ), $class );
  }
  
  sub target_manifest {
    my $this = shift;
    my $basedir = $TWiki::Contrib::Build::basedir;
    chdir("$basedir") || die "can't cd to $basedir - $!";
    print `find . -type f | grep -v CVS | egrep -v '~\$' | egrep "([tT][rR]efactor|LICENSE*)" > $basedir/MANIFEST`;
  }
  
  sub filter {
    my $this = shift;
    my ( $from, $to ) = @_;
    return $this->SUPER::filter( $from, $to ) if ( $from =~ m/[a-zA-Z0-9_]+\.pl/ || $from =~ m/TRefactorAddOn\.txt/ );
  }
}

# Create the build object
$build = new TRefactorAddOnBuild();

# Build the target on the command line, or the default target
$build->build($build->{target});
