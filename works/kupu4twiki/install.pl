use strict;
use ExtUtils::MakeMaker;

print("Kupu For TWiki v1.0 beta2\n");
print("Installation script\n");

my $rootDir = "";
my $toeval = "";

sub promptUser {
  my ($msg, $default) = @_;
  my $vRet = ExtUtils::MakeMaker::prompt($msg . " [" . $default . "]");
  if ($vRet) { return $vRet; }
  return $default;
}

$rootDir = promptUser("TWiki installation directory ?", "/twiki/");
if ($rootDir =~ /.*[^\/]$/ ){
  $rootDir = $rootDir . "/";
}

my $bin = promptUser("TWiki scripts directory ?", "bin");

print("> Copying Kupu scripts...\n");

$toeval = "cp bin/* " . $rootDir . "$bin";
`$toeval`;

print("> Detecting scripts header...\n");

$toeval = "ls " . $rootDir . "$bin \| grep \-E \"\^edit(\\..\+)\?\$\"";
my $file = `$toeval`;

$toeval = "head \-1 " . $rootDir . "$bin/" . $file;
my $header = `$toeval`;

$toeval = "perl \-pi\~ \-e \'s;\#\!/usr/bin/perl \-wT;$header;\' ".$rootDir."$bin/html2twiki ".$rootDir."$bin/kupuedit ".$rootDir."$bin/kupu_attachments ".$rootDir."$bin/twiki2html";
`$toeval`;

print("> Copying Kupu modules...\n");

$toeval = "mkdir " . $rootDir . "lib/Kupu";
`$toeval`;

$toeval = "cp lib/Kupu/* " . $rootDir . "lib/Kupu";
`$toeval`;

$toeval = "cp lib/varmap.cfg lib/imgmap.cfg " . $rootDir . "lib";
`$toeval`;

print("> Copying Kupu files...\n");

$toeval = "cp -r kupu " . $rootDir;
`$toeval`;

print("> Setting up permissions...\n");

$toeval = "chmod 755 " . $rootDir."$bin/html2twiki ".$rootDir."$bin/kupuedit ".$rootDir."$bin/kupu_attachments ".$rootDir."$bin/twiki2html ".$rootDir."$bin/htmltotwiki.jar";
`$toeval`;

$toeval = "chmod -R 755 " . $rootDir . "kupu";
`$toeval`;

$toeval = "chmod 755 " . $rootDir . "lib/varmap.cfg " . $rootDir . "lib/imgmap.cfg";
`$toeval`;

$toeval = "chmod -R 755 " . $rootDir . "lib/Kupu";
`$toeval`;

print("> Copying Kupu templates...\n");

$toeval = "cp templates/kupu*.tmpl " . $rootDir . "templates";
`$toeval`;

$toeval = "chmod 755 " . $rootDir . "templates/kupu*.tmpl";
`$toeval`;

print("\nIMPORTANT : Read README.TXT to complete install procedure\n\n");

