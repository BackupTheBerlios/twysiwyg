package Service::Conversions;

# SOAP Conversions Module
# Authors : Maxime Lamure & Romain Raugi

use strict;
use SOAP::Lite;

use vars qw(%month_names);

%month_names = ( "Jan" => "01",
                 "Feb" => "02",
                 "Mar" => "03",
                 "Apr" => "04",
                 "May" => "05",
                 "Jun" => "06",
                 "Jul" => "07",
                 "Aug" => "08",
                 "Sep" => "09",
                 "Oct" => "10",
                 "Nov" => "11",
                 "Dec" => "12"
);

sub soap_boolean {
  my ( $name, $value ) = @_;
  my $v = SOAP::Data->name($name => $value)->type('boolean');
  return $v;
}

sub soap_connection_info {
  my ( $name, $key, $timeout, $subwebs, $adminLock, $locks_refresh, $allowCompleteRemove ) = @_;
  my $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name(key => int($key)),
                                                       SOAP::Data->name(timeout => int($timeout)),
                                                       SOAP::Data->name(subwebs => $subwebs)->type('boolean'),
                                                       SOAP::Data->name(adminLock => $adminLock)->type('boolean'),
                                                       SOAP::Data->name(locksActualization => $locks_refresh)->type('boolean'),
                                                       SOAP::Data->name(completeRemoveAllowed => $allowCompleteRemove)->type('boolean')));
  return $v;
}

sub soap_user {
  my ( $name, $usage, $login, $cnx ) = @_;
  my ( $day, $month, $dayom, $hour, $minute, $second, $year ) = split/[ :]+/, $cnx, 7;
  # Format 0X
  $dayom = "0".$dayom if (int($dayom) < 10);
  my $date = $year."-".$month_names{$month}."-".$dayom."T".$hour.":".$minute.":".$second;

  my $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name(usage => $usage),
                                                       SOAP::Data->name(login => $login),
                                                       SOAP::Data->name(connection => $date)->type('timeInstant')));
  return $v;
}

sub soap_array {
  my ( $name, @values ) = @_;
  my $v;
  if ($#values >= 0) {
    $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name($name => @values)));
  } else {
    $v = SOAP::Data->name($name => undef);
  }
  return $v;
}

sub soap_topic
{
 my ($name,%hash) = @_;
 my $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name(web => $hash{web})->type('string'),
                                                      SOAP::Data->name(name => $hash{topic})->type('string'),
                                                      SOAP::Data->name(author => $hash{author})->type('string'),
                                                      SOAP::Data->name(date => $hash{date})->type('int'),
                                                      SOAP::Data->name(format => $hash{format})->type('string'),
                                                      SOAP::Data->name(version => $hash{version})->type('string'),
                                                      SOAP::Data->name(parent => $hash{parent})->type('string'),
                                                      SOAP::Data->name(data => $hash{data})->type('string')));
 return $v;
}

sub soap_attach
{

 my ($name,%hash) = @_;
 my $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name(name => $hash{name})->type('string'),
                                                      SOAP::Data->name(attr => $hash{attr})->type('string'),
                                                      SOAP::Data->name(comment => $hash{comment})->type('string'),
                                                      SOAP::Data->name(date => $hash{date})->type('int'),
                                                      SOAP::Data->name(size => $hash{size})->type('int'),
                                                      SOAP::Data->name(path => $hash{path})->type('string'),
                                                      SOAP::Data->name(user => $hash{user})->type('string'),
                                                      SOAP::Data->name(version => $hash{version})->type('string')));
 return $v;
}

sub soap_array_string {
  my ( $name, @values ) = @_;
  my $v;
  if ($#values >= 0) {
    $v = SOAP::Data->name($name => \SOAP::Data->value(SOAP::Data->name($name => @values)->type('string')));
  } else {
    $v = SOAP::Data->name($name => undef);
  }
  return $v;
}


1;