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
{ package KupuEditorAddOnBuild;

  @KupuEditorAddOnBuild::ISA = ( "TWiki::Contrib::Build" );

  sub new {
    my $class = shift;
    return bless( $class->SUPER::new( "KupuEditorAddOn" ), $class );
  }
  
  sub target_manifest {
    my $this = shift;
    my $basedir = $TWiki::Contrib::Build::basedir;
    chdir("$basedir") || die "can't cd to $basedir - $!";
    print `find . -type f | grep -v CVS | egrep -v '~\$' | egrep "([kK]upu|LICENSE*)" > $basedir/MANIFEST`;
  }
  
  sub filter {
    my ($this, $from, $to) = @_;
    # Nothing
  }

}

# Create the build object
$build = new KupuEditorAddOnBuild();

# Build the target on the command line, or the default target
$build->build($build->{target});
