# TWiki KupuEditorAddOn HTML2TWiki Module
#
# TWiki KupuEditorAddOn add-on for TWiki
# Copyright (C) 2004 Damien Mandrioli and Romain Raugi
# 
# Based on parts of TWiki.
# Copyright (C) 1999-2004 Peter Thoeny, peter@thoeny.com
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

package TWiki::Contrib::KupuEditorAddOn::Html2TWiki;

use strict;
use TWiki;

use vars qw( $imgmap );

=pod
---++ convertUtf8toSiteCharset( $text )
Generic encoding subroutine. Require TWiki init.
=cut
sub convertUtf8toSiteCharset {
  my ( $text ) = @_;
  my $charEncoding;

  # Convert into ISO-8859-1 if it is the site charset
  if ( $TWiki::siteCharset =~ /^iso-?8859-?1$/i ) {
    # ISO-8859-1 maps onto first 256 codepoints of Unicode
    # (conversion from 'perldoc perluniintro')
    $text =~ s/ ([\xC2\xC3]) ([\x80-\xBF]) / 
    chr( ord($1) << 6 & 0xC0 | ord($2) & 0x3F )
    /egx;
  } elsif ( $TWiki::siteCharset eq "utf-8" ) {
    # Convert into internal Unicode characters if on Perl 5.8 or higher.
    if( $] >= 5.008 ) {
      require Encode;			# Perl 5.8 or higher only
      $text = Encode::decode("utf8", $text);	# 'decode' into UTF-8
    } else {
      TWiki::writeWarning "UTF-8 not supported on Perl $] - use Perl 5.8 or higher.";
    }
    TWiki::writeWarning "UTF-8 not yet supported as site charset - TWiki is likely to have problems";
  } else {
    # Convert from UTF-8 into some other site charset
    TWiki::writeDebug "Converting from UTF-8 to $TWiki::siteCharset";
    # Use conversion modules depending on Perl version
    if( $] >= 5.008 ) {
      require Encode;			# Perl 5.8 or higher only
      import Encode qw(:fallbacks);
      # Map $siteCharset into real encoding name
      $charEncoding = Encode::resolve_alias( $TWiki::siteCharset );
      if( not $charEncoding ) {
        TWiki::writeWarning "Conversion to \$TWiki::siteCharset '$TWiki::siteCharset' not supported, or name not recognised - check 'perldoc Encode::Supported'";
      } else {
        # Convert text using Encode:
        # - first, convert from UTF8 bytes into internal (UTF-8) characters
        $text = Encode::decode("utf8", $text);	
        # - then convert into site charset from internal UTF-8,
        # inserting \x{NNNN} for characters that can't be converted
        $text = Encode::encode( $charEncoding, $text, &FB_PERLQQ );
        ##writeDebug "Encode result is $fullTopicName";
      }
    } else {
      require Unicode::MapUTF8;	# Pre-5.8 Perl versions
      $charEncoding = $TWiki::siteCharset;
      if( not Unicode::MapUTF8::utf8_supported_charset($charEncoding) ) {
        TWiki::writeWarning "Conversion to \$TWiki::siteCharset '$TWiki::siteCharset' not supported, or name not recognised - check 'perldoc Unicode::MapUTF8'";
      } else {
        # Convert text
        $text = Unicode::MapUTF8::from_utf8({ 
                -string => $text, -charset => $charEncoding });
        # FIXME: Check for failed conversion?
      }
    }
  }
  return $text;
}

=pod
---++ translate( $content )
HTML 2 TWiki Translation. 
=cut
sub translate {
  my ( $webName, $topicName, $content ) = @_;
  
  my $host = $TWiki::defaultUrlHost;
  $host =~ s/^(.*)\/$/$1/;
  
  # TWiki Icons
  do "$TWiki::dataDir/kupu_imgmap.cfg";
  my @map = split/\n/, $imgmap;
  foreach my $exp ( @map ) {
    my ( $syntax, $icon ) = split/ /, $exp;
    # There is a particular syntax :
    if ( $icon ) {
      $icon =~ s/\/(.*)/$1/;
      $content =~ s/<img\s+src=([\"\'])$host\/$icon\1[^>]*>/$syntax/gi;
    }
  }
  # Values correction
  my $pub = $TWiki::pubUrlPath;
  $pub =~ s/^(.*)\/$/$1/;
  $pub =~ s/^\/(.*)$/$1/;
  $content =~ s/(src|href)=([\'\"])($host)?\/?$pub\/$webName\/$topicName/$1\=$2%ATTACHURL%/gi;
  # Bullets
  $content =~ s/\n\s{3}\*/\n\t\*/g;
  $content =~ s/\n\s{3}([0-9+])/\n\t$1/g;
  $content =~ s/\n\s{6}\*/\n\t\t\*/g;
  $content =~ s/\n\s{6}([0-9+])/\n\t\t$1/g;
  $content =~ s/\n\s{9}\*/\n\t\t\t\*/g;
  $content =~ s/\n\s{9}([0-9+])/\n\t\t\t$1/g;

  return $content;
}

1;