# TWiki KupuEditorAddOn TWiki2HTML Module
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

package TWiki::Contrib::KupuEditorAddOn::TWiki2Html;

use strict;
use TWiki;

use vars qw( $imgmap );

=pod
---++ translate( $webName, $topicName, $content )
TWiki 2 HTML Translation. 
=cut
sub translate {
  my ( $webName, $topicName, $content ) = @_;
  
  # Save & Extract Verbatim Code 4 further treatments
  my @verbatim = ();
  $content = TWiki::takeOutVerbatim( $content, \@verbatim );
  $content =~ s/\\\n//g;
  
  # Permissions
  my $view_perm = '';
  my $change_perm = '';
  if ( $content =~ s/\n\t\*\s*SETALLOWTOPICVIEW\s*=\s*(.*)// ) { $view_perm = $1; }
  if ( $content =~ s/\n\t\*\s*SETALLOWTOPICCHANGE\s*=\s*(.*)// ) { $change_perm = $1; }
  $view_perm =~ s/ //;
  $change_perm =~ s/ //;
  
  # Take out links to replace displayed variables
  my $i = 0;
  my @refs = ();
  $content =~ s/(href|src|action)=\"([^"]+)\"/&_link($1, $2, \@refs, $i++)/gei;
  $content =~ s/\[([^\[\]<>]+)\]/&_tlink($1, \@refs, $i++)/gei;
  
  my $host = $TWiki::defaultUrlHost;
  $host =~ s/^(.*)\/$/$1/;
  
  # TWiki Icons
  do "$TWiki::dataDir/kupu_imgmap.cfg";
  my @map = split/\n/, $imgmap;
  foreach my $exp ( @map ) {
    my ( $syntax, $icon ) = split/ /, $exp;
    if ( $icon ) {
      $syntax =~ s/([\(\)\:\/\{\}\*\\\[\]\^\$])/\\$1/g;
      $icon =~ s/\/(.*)/$1/;
      $content =~ s/$syntax/<img src=\"$host\/$icon\"\/>/g;
    }
  }
  
  # Twiki Variables
  $content =~ s/%([A-Z0-9]+)\{\"([^"]*)\"\}%/<span class=\"variable\">$1\{$2\}<\/span>/gi;
  $content =~ s/%([A-Z0-9]+)\{\'([^']*)\'\}%/<span class=\"variable\">$1\{$2\}<\/span>/gi;
  $content =~ s/%([A-Z0-9]+)\{([^}]*)\}%/<span class=\"variable\">$1\{$2\}<\/span>/gi;
  $content =~ s/%([A-Z0-9]+)%/<span class=\"variable\">$1<\/span>/gi;
  
  # Restore links
  $content =~ s/%_REF([0-9]+)%/$refs[int($1)]/gei;
  
  # Twiki Render
  $content = &TWiki::handleCommonTags( $content, $topicName, $webName );
  $content = &TWiki::Render::getRenderedVersion( $content );
  
  # Corrects <nop>
  $content =~ s/<\/?nop\/?>//gi;
  
  my $bin = $TWiki::scriptUrlPath;
  $bin =~ s/^(.*)\/$/$1/;
  $bin =~ s/^\/(.*)$/$1/;
  # Rename internal links class
  $content =~ s/twiki(Anchor)?Link/internal_link/gi;
  # New links
  $content =~ s/<span\s+class=\"twikiNewLink\"[^>]*>\s*<[^>]*>([^>]*)<[^>]*>\s*<a\s+href=\"([^\?]+)\?[^\"]*\">\s*<sup>\?<\/sup>\s*<\/a>\s*<\/span>/"<a class=\"internal_link\" href=\"". &_hrefFromNewLink($2)."\">$1<\/a>"/gei;
  # URL
  my $pattern = "href=\"($host)?\/?$bin\/view$TWiki::scriptSuffix\/([^/]+)\/([^\"]+)\"([^>]*)>([^<]*)<";
  $content =~ s/$pattern/"href=\"".( ( $2 ne $webName )? "$2.$3" : "$3" )."\"$4>".
              ( ( ( $5 eq $3 || $5 eq $2 ) && ( $2 ne $webName ) ) ? "$2.$3" : "$3"  ) ."<"/gei;
  
  # Restore Verbatim Code
  $content = TWiki::putBackVerbatim( $content, "pre", @verbatim );
  $content =~ s|\n?<nop>\n$||o;
  
  # Delete automatically generated anchors in titles
  $content =~ s/(<h[1-6]>)\s*<a[^>\n]*>\s*<\/a>(.*)/$1$2/gi;
  
  # HTML Response
  return "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
  <html>
    <head>
      <meta http-equiv=\"Content-Type\" content=\"text\/html; charset=$TWiki::siteCharset\" />
      <meta name=\"view_permissions\" content=\"$view_perm\"\/>
      <meta name=\"change_permissions\" content=\"$change_perm\"\/>
      <style type=\"text\/css\">
        xml { display:none; }
        .variable {
          border: 1px solid green;
          padding-left:2px;
          padding-right:2px;
          background-color:#DDFFDD;
          color:green;
        }
        a.internal_link { background-color:#DDDDFF;border:1px solid #4444FF;padding-left:2px;padding-right:2px; }
      </style>
    </head>
    <body>
      $content
    </body>
  </html>";
}

=pod
---++ _link( $action, $val, $refs, $i )
Extract external references. 
=cut
sub _link() {
  my ( $action, $val, $refs, $i ) = @_;
  $refs->[$i] = $val;
  return "$action=\"%_REF$i%\"";
}

=pod
---++ _tlink( $val, $refs, $i )
Extract TWiki references.  
=cut
sub _tlink() {
  my ( $val, $refs, $i ) = @_;
  $refs->[$i] = $val;
  return "\[%_REF$i%\]";
}

=pod
---++ _hrefFromNewLink( $href )
Extract New Page from Ref.  
=cut
sub _hrefFromNewLink {
  my ( $href ) = @_;
  $href =~ s/edit/view/;
  return $href;
}
1;