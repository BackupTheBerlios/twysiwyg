package Kupu::Html2TWiki;

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
		    ##writeDebug "Converting with Encode, valid 'to' encoding is '$charEncoding'";
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
		    ##writeDebug "Converting with Unicode::MapUTF8, valid encoding is '$charEncoding'";
		    $text = Unicode::MapUTF8::from_utf8({ 
			    			-string => $text, 
		    			 	-charset => $charEncoding });
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
  # XML
  $content =~ s/(<xml\s*\/>|<xml>|<\/xml>)//gi;
  # [[ => [<nop\/>[
  $content =~ s/\[\[/\[<nop\/>\[/gi;
    
  # TWiki Icons
  do "imgmap.cfg";
  my @map = split/\n/, $imgmap;
  foreach my $exp ( @map ) {
    my ( $syntax, $icon ) = split/ /, $exp;
    # There is a particular syntax :
    if ( $icon ) {
      $icon =~ s/\/(.*)/$1/;
      $content =~ s/<img\s+src=([\"\'])$TWiki::defaultUrlHost$icon\1[^>]*>/$syntax/gi;
    }
  }
  
  # Variables ( several passes )
  while ( $content =~ m/<span\s+class=\"variable\"\s*>([^<]*)<\/span\s*>/gi ) {
    $content =~ s/<span\s+class=\"variable\"\s*>([^<]*)<\/span\s*>/%$1%/gi;
  }
  $content =~ s/%(.+)\{(.*)\}%/%$1\{\"$2\"\}%/gi;
  # Values correction (After TWiki Initialization)
  my $pub = $TWiki::pubUrlPath;
  $pub =~ s/\/(.*)/$1/;
  $content =~ s/(src|href)=([\'\"])($TWiki::defaultUrlHost)?\/?$pub\/$webName\/$topicName/$1\=$2%ATTACHURL%/gi;
  my $bin = $TWiki::scriptUrlPath;
  $bin =~ s/\/(.*)/$1/;
  $content =~ s/(src|href)=([\'\"])($TWiki::defaultUrlHost)?\/?$bin\/view$TWiki::scriptSuffix\/$webName(\/|\.)(\w+)/$1\=$2$5/gi;
  $content =~ s/(src|href)=([\'\"])($TWiki::defaultUrlHost)?\/?$bin\/view$TWiki::scriptSuffix\/(\w+)(\/|\.)(\w+)/$1\=$2$4\.$6/gi;
  # Permissions
  my $view_perms = "";
  my $change_perms = "";
  if ( $content =~ s/<meta\s+name=\"view_permissions\"\s+content=\"([^\"]+)\"\s*\/?>//i ) { $view_perms = $1; }
  if ( $content =~ s/<meta\s+name=\"change_permissions\"\s+content=\"([^\"]+)\"\s*\/?>//i ) { $change_perms = $1; }
  if ( $content =~ s/<meta\s+content=\"([^\"]+)\"\s+name=\"view\_permissions\"\s*\/?>//i ) { $view_perms = $1; }
  if ( $content =~ s/<meta\s+content=\"([^\"]+)\"\s+name=\"change\_permissions\"\s*\/?>//i ) { $change_perms = $1; }
  # <br/>
  $content =~ s/<br[^\/>]*\/?>/\n/gi;
  # <nop>
  $content =~ s/\[<nop\s*\/?>\[/\!\[\[/gi;
  $content =~ s/<\/?nop\s*\/?>//gi;
  
  open( TMP, ">$TWiki::dataDir/$webName/$topicName.tmp" );
  print TMP $content;
  close( TMP );

  # Calling Java Parser
  system "java -jar htmltotwiki.jar $TWiki::dataDir/$webName/$topicName.tmp";

  # Retrieve Twiki formated Topic
  $content = "";
  open( TMP, "$TWiki::dataDir/$webName/$topicName.tmp" );
  while (<TMP>) { $content .= "$_" }
  close( TMP );

  # Delete temp file
  unlink( "$TWiki::dataDir/$webName/$topicName.tmp" );

  # Bullets
  $content =~ s/\n\s{3}\*/\n\t\*/g;
  $content =~ s/\n\s{3}([0-9+])/\n\t$1/g;
  $content =~ s/\n\s{6}\*/\n\t\t\*/g;
  $content =~ s/\n\s{6}([0-9+])/\n\t\t$1/g;
  $content =~ s/\n\s{9}\*/\n\t\t\t\*/g;
  $content =~ s/\n\s{9}([0-9+])/\n\t\t\t$1/g;
  # WikiWords
  $content =~ s/\[\[([^\]]+)\]\[\1\]\]/$1/gi;
  # Permissions
  $content .= &perm( "\n\t* SETALLOWTOPICVIEW = $view_perms" ) if ( $view_perms );
  $content .= &perm( "\n\t* SETALLOWTOPICCHANGE = $change_perms" ) if ( $change_perms );

  return $content;
}

=pod
---++ perm( $line )
Special process for permissions line. 
=cut
sub perm {
  my ( $perm_line ) = @_;
  $perm_line =~ s/,/, /g;
  $perm_line =~ s/<nop\s*\/?>//g;
  return $perm_line;
}

1;