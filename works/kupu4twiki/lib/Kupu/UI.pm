package Kupu::UI;

use strict;
use TWiki;
use TWiki::Form;
use TWiki::Plugins;
use TWiki::Prefs;
use TWiki::Store;
use TWiki::UI;

use vars qw( $imgmap $varmap );

sub kupuedit {
  my ( $webName, $topic, $userName, $query ) = @_;
  my $breakLock = $query->param( 'breaklock' ) || "";
  my $onlyWikiName = $query->param( 'onlywikiname' ) || "";
  my $onlyNewTopic = $query->param( 'onlynewtopic' ) || "";
  my $formTemplate  = $query->param( "formtemplate" ) || "";
  my $templateTopic = $query->param( "templatetopic" ) || "";
  my $cgiAppType = $query->param( 'apptype' ) || "text/html";
  my $skin = $query->param( "skin" );
  my $theParent = $query->param( 'topicparent' ) || "";
  my $ptext = $query->param( 'text' );

  my $getValuesFromFormTopic = ( ( $formTemplate ) && ( ! $ptext ) );

  return unless TWiki::UI::webExists( $webName, $topic );

  return if TWiki::UI::isMirror( $webName, $topic );

  my $tmpl = "";
  my $text = "";
  my $meta = "";
  my $extra = "";
  my $topicExists  = &TWiki::Store::topicExists( $webName, $topic );

  # Prevent editing existing topic?
  if( $onlyNewTopic && $topicExists ) {
    # Topic exists and user requested oops if it exists
    TWiki::UI::oops( $webName, $topic, "createnewtopic" );
    return;
  }

  # prevent non-Wiki names?
  if( ( $onlyWikiName )
      && ( ! $topicExists )
      && ( ! ( &TWiki::isWikiName( $topic ) || &TWiki::isAbbrev( $topic ) ) ) ) {
    # do not allow non-wikinames, redirect to view topic
    TWiki::UI::redirect( TWiki::getViewUrl( $webName, $topic ) );
    return;
  }

  # Read topic 
  if( $topicExists ) {
    ( $meta, $text ) = &TWiki::Store::readTopic( $webName, $topic );
  }

  my $wikiUserName = &TWiki::userToWikiName( $userName );
  return unless TWiki::UI::isAccessPermitted( $webName, $topic,
                                            "change", $wikiUserName );

  # Check for locks
  my( $lockUser, $lockTime ) = &TWiki::Store::topicIsLockedBy( $webName, $topic );
  if( ( ! $breakLock ) && ( $lockUser ) ) {
    # warn user that other person is editing this topic
    $lockUser = &TWiki::userToWikiName( $lockUser );
    use integer;
    $lockTime = ( $lockTime / 60 ) + 1; # convert to minutes
    my $editLock = $TWiki::editLockTime / 60;
    TWiki::UI::oops( $webName, $topic, "locked",
                     $lockUser, $editLock, $lockTime );
    return;
  }
  &TWiki::Store::lockTopic( $topic );

  my $templateWeb = $webName;

  # Get edit template, standard or a different skin
  $skin = TWiki::Prefs::getPreferencesValue( "SKIN" ) unless ( $skin );
  $tmpl = &TWiki::Store::readTemplate( "kupuedit", $skin );
  unless( $topicExists ) {
    if( $templateTopic ) {
      if( $templateTopic =~ /^(.+)\.(.+)$/ ) {
        # is "Webname.SomeTopic"
        $templateWeb   = $1;
        $templateTopic = $2;
      }

      ( $meta, $text ) = &TWiki::Store::readTopic( $templateWeb, $templateTopic );
    } elsif( ! $text ) {
      ( $meta, $text ) = &TWiki::Store::readTemplateTopic( "WebTopicEditTemplate" );
    }
    $extra = "(not exist)";

    # If present, instantiate form
    if( ! $formTemplate ) {
      my %args = $meta->findOne( "FORM" );
      $formTemplate = $args{"name"};
    }

    $text = TWiki::expandVariablesOnTopicCreation( $text, $userName );
  }

  # parent setting
  if( $theParent eq "none" ) {
    $meta->remove( "TOPICPARENT" );
  } elsif( $theParent ) {
    if( $theParent =~ /^([^.]+)\.([^.]+)$/ ) {
      my $parentWeb = $1;
      if( $1 eq $webName ) {
        $theParent = $2;
      }
    }
    $meta->put( "TOPICPARENT", ( "name" => $theParent ) );
  }
  $tmpl =~ s/%TOPICPARENT%/$theParent/;

  # Processing of formtemplate - comes directly from query parameter formtemplate , 
  # or indirectly from webtopictemplate parameter.
  my $oldargsr;
  if( $formTemplate ) {
    my @args = ( name => $formTemplate );
    $meta->remove( "FORM" );
    if( $formTemplate ne "none" ) {
      $meta->put( "FORM", @args );
    } else {
      $meta->remove( "FORM" );
    }
    $tmpl =~ s/%FORMTEMPLATE%/$formTemplate/go;
    if( defined $ptext ) {
      $text = $ptext;
      $text = &TWiki::Render::decodeSpecialChars( $text );
    }
  }

  $text =~ s/&/&amp\;/go;
  $text =~ s/</&lt\;/go;
  $text =~ s/>/&gt\;/go;
  $text =~ s/\t/   /go;
  
  #/AS

  if( $TWiki::doLogTopicEdit ) {
    # write log entry
    &TWiki::Store::writeLog( "edit", "$webName.$topic", $extra );
  }

  $tmpl = &TWiki::handleCommonTags( $tmpl, $topic );
  $tmpl = &TWiki::Render::getRenderedVersion( $tmpl );

  # Don't want to render form fields, so this after getRenderedVersion
  my %formMeta = $meta->findOne( "FORM" );
  my $form = "";
  $form = $formMeta{"name"} if( %formMeta );
  $tmpl =~ s/%FORMFIELDS%//go;

  $tmpl =~ s/%FORMTEMPLATE%//go; # Clear if not being used
  $tmpl =~ s/%TEXT%/$text/go;
  $tmpl =~ s/( ?) *<\/?(nop|noautolink)\/?>\n?/$1/gois;   # remove <nop> and <noautolink> tags
  
  # All Topics
  my @webs = &TWiki::Store::getAllWebs();
  
  my $cws = "";
  my @topics = &TWiki::Store::getTopicNames( $webName );
  foreach my $topic ( @topics ) {
    $cws .= "<option value=\"$topic\">$topic<\/option>";
  }
  $tmpl =~ s/%KUPU{"WEBTOPICS"}%/$cws/go;
  
  if ( $tmpl =~ /%KUPU{"ALLTOPICS"}%/ ) {
    my $ws = "";
    foreach my $web ( sort @webs ) {
      @topics = &TWiki::Store::getTopicNames( $web );
      foreach my $topic ( @topics ) {
        $ws .= "<option value=\"$web.$topic\">$web.$topic<\/option>";
      }
    }
    $tmpl =~ s/%KUPU{"ALLTOPICS"}%/$ws/go;
  }
  
  # TWiki Icons
  do "imgmap.cfg";
  my $icons = "";
  my @map = split/\n/, $imgmap;
  my $host = $TWiki::defaultUrlHost;
  $host =~ s/^(.*)\/$/$1/;
  foreach my $exp ( @map ) {
    my ( $syntax, $icon ) = split/ /, $exp;
    $icon = $syntax if ( ! $icon );
    if ( $icon ) {
      my $filename = $icon;
      $filename =~ s/$TWiki::pubUrlPath/$TWiki::pubDir/;
      $icon =~ s/^\/(.*)$/$1/;
      $icons .= "<img src=\"$host\/$icon\" hspace=\"3\"/>" if ( -e "$filename" );
    }
  }
  $tmpl =~ s/%TWIKIICONS%/$icons/go;
  
  # TWiki Icons
  do "varmap.cfg";
  my $vars = "";
  @map = split/\n/, $varmap;
  foreach my $exp ( sort @map ) {
    my ( $var_name, $label );
    ( $var_name, $label ) = split/ /, $exp, 2;
    $label = "$var_name : $label";
    $var_name =~ s/%//g;
    $vars .= "<option value=\"$var_name\">$label</option>" if ( $var_name );
  }
  $tmpl =~ s/%KUPU{"TWIKIVARS"}%/$vars/go;
  
  TWiki::writeHeaderFull ( $query, 'edit', $cgiAppType, length($tmpl) );

  print $tmpl;
}

1;