#!/usr/bin/perl -w

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
    print `find . -type f | grep -v CVS | egrep -v '~\$' | egrep "([kK]upu|LICENSE*|Twiki*)" > $basedir/MANIFEST`;
  }
  
  sub filter {
    my $this = shift;
    my ( $from, $to ) = @_;
    return $this->SUPER::filter( $from, $to ) if ( $from =~ m/KupuEditorAddOn_installer\.pl/ || $from =~ m/KupuEditorAddOn\.txt/ );
  }

}

# Create the build object
$build = new KupuEditorAddOnBuild();

# Build the target on the command line, or the default target
$build->build($build->{target});
