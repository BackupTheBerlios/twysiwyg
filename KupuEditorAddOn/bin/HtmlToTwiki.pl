# Copyright (C) 2004 Frederic Luddeni, frederic.luddeni@wanadoo.fr
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at 
# http://www.gnu.org/copyleft/gpl.html
#
# VERSION 1.01
#
#
# HISTORY:
# ========
# Version 1.01: 
# -------------
# ADDED:
# * simpleTagProcess	: Allows to process simple tag.
# * styleProcess		: Allows to process the style tags and composed tags.
# * preformattedProcess : Allows to process the preformatted tag.
# DELETED:
# * titleProcess 					: Replaced by simpleTagProcess
# * paragraphProcess 				: Replaced by simpleTagProcess
# * simpleHtmlTagProcess			: Replaced by simpleTagProcess
# * verbatimProcess		 			: Replaced by preformattedProcess
# * styleProcess, fixedFontProcess	: Replaced by styleProcess
#
# Version 1.00 (THE FIRST VERSION):
# ---------------------------------
# It's a translation of HtmlToTwiki.java which has been optimizing
# and debugging.

=begin twiki

---+ TWiki::Translator::HtmlToTwiki Module

This package contains routines for translate html syntax to twiki syntax

=cut

package TWiki::Translator::HtmlToTwiki;

use strict;use warnings;

use HTML::TreeBuilder;
use HTML::Element;

my $TRUE = 1;
my $FALSE = 0;
my $DEBUG_MODE = $FALSE;

my $WIKIWORD_PROTECTION_TAG = "<nop>";
my $TWIKI_TITLE_LEVEL1 = "---+ ";
my $TWIKI_TITLE_LEVEL2 = "---++ ";
my $TWIKI_TITLE_LEVEL3 = "---+++ ";
my $TWIKI_TITLE_LEVEL4 = "---++++ ";
my $TWIKI_TITLE_LEVEL5 = "---+++++ ";
my $TWIKI_TITLE_LEVEL6 = "---++++++ ";
my $TWIKI_TITLE_ENDINGTAG = "\n";
my $TWIKI_BOLD = "*";
my $TWIKI_ITALIC= "_";
my $TWIKI_BOLD_ITALIC= "__";
my $TWIKI_FIXEDFONT = "=";
my $TWIKI_BOLD_FIXEDFONT = "==";
my $TWIKI_VERBATIM_OPENINGTAG = "<VERBATIM>";
my $TWIKI_VERBATIM_CLOSINGTAG = "</VERBATIM>";
my $TWIKI_SEPARATOR = "---";
my $TWIKI_NEXT_LINE = "<BR/>";

my $TWIKI_LIST_INDENTSTEP = "   ";  # amount before * in lists Added by ColasNahaboo
my $TWIKI_LIST_TAG = "*";
my $TWIKI_ORDERLIST_TAG = "1";
my $TWIKI_DEFINITIONLIST_TAG = "   \$ ";

my $WIKIWORDCLASS = "TWIKIWIKIWORD";


my $MARGIN = "";

&main(@ARGV);

sub main{
    my($fileName) = @_; # === TODO Replace by htmlText ===
   
    my $tree = HTML::TreeBuilder->new; # empty tree
   
    # Begin  === TODO delete After integration. Used to simulate the $sText variable  ===
    my $htmlText = " ";
    
    if ( $fileName ne "" ) {
      open(F, $fileName);
      while(my $ligne = <F>){ $htmlText .= $ligne; }
      close F;
    }
    else {
      while(my $ligne = <STDIN>){ $htmlText .= $ligne; }
    }
    # End === TODO delete After integration. Used to simulate the $sText variable ===
   
    # Regex used to replace the tag forms <XXX/> by <XXX></XXX>.
    #These tag forms aren't managed by TreeBuilder
    $htmlText =~ s/<([^ \t\n\r\/>]+)(.*?)\/>/<$1$2><\/$1>/g;
   
    debug("HTMLTEXT BEFORE THE PROCESSING:\n$htmlText\n\n");
    $tree->no_space_compacting($TRUE);
    $tree->parse($htmlText);
    
    my $twikiText = &processTranslate($tree, $FALSE, $TRUE);
    debug("TWIKITEST AFTER THE PROCESSING:\n$twikiText\n\n");
    print $twikiText;
    
    $tree = $tree->delete;
}

##############################################################################################
##############################################################################################
##############################################################################################

################################ DONE ################################
=pod
---++ isNewLine($sText)
Tests if the chain $sText ends with "\n".

$sText	: The chain

Returns : $TRUE if the character "\n" is a suffix of $sText; $FALSE otherwise
=cut
sub isNewLine{
    my ($sText) = @_;

	return ($sText =~ /((.*?)\n($MARGIN)?$)/)?$TRUE:$FALSE;
}

################################ DONE ################################
=pod
---++ trimChain($sText)
Returns a copy of the chain, with leading and trailing whitespace omitted

$sText	: The chain

Returns : A copy of this chain with leading and trailing white space removed,
		  or this chain if it has no leading or trailing white space
=cut
sub trimChain{
    my ($sText) = @_;
    $sText =~ s/(^[\s]*)(.*?)([\s]*$)/$2/;
    
    return $sText;
}

################################ DONE ################################
=pod
---++ processTranslate($node, $activeSpace, $newLine)
Used to translate all the html node type (Element and text) to the 
twiki syntax.

$node       	: The node to translate.
$activeSpace    : Allows to know if the escape characters must be 
				  displayed or not.
$newLine    	: Allows to know If one is placed on a new line

Returns : A twiki syntax chain of this given node.
=cut
sub processTranslate {
    my($node, $activeSpace, $newLine)= @_;

    my $sText = "";

    # Allows to know if the node is not empty...
    if($node ne ""){  
        # If $node is an element
        if(ref($node)){
            $sText .= &nodeProcess($node, $activeSpace, $newLine);
            
        # If the node is a text node 
        }else{
            my $sNodeValue = $node;
        	if(!$activeSpace){            
            	if($newLine){
                	$sNodeValue =~ s/^\n//g;
            	}

            	$sNodeValue =~ s/(\n){2,}/\n/g;
            	$sNodeValue =~ s/([ \t\f\r])+/ /g;
       	     	$sNodeValue =~ s/^([ \n])+$//g;
        	    $sText .= ($sNodeValue ne "\n" && $sNodeValue ne "")? &wikiwordProtectionProcess($sNodeValue) : "";
        	}else{
        		$sText .= &wikiwordProtectionProcess($sNodeValue);
        	}
        }
    }
    return $sText;
}

################################ DONE ################################
=pod
---++ wikiwordProtectionProcess( $sNodeValue)
Used to find and protect all the words having the same syntax that the
WikiWord.

$sNodeValue	: The Sentence which have been to process

Returns : $sNodeValue with all no WikiWord protected.
=cut
sub wikiwordProtectionProcess{
    my($sNodeValue) = @_;
    $sNodeValue =~ s/( |^)([A-Z]+[a-z]+[A-Z]([a-zA-Z]*?))/$1$WIKIWORD_PROTECTION_TAG$2/g;
    return $sNodeValue;
}

################################ DONE ################################
=pod
---++ nodeProcess( $node, $activeSpace, $newLine)
Used to translate all the html Element node to the twiki syntax.

$node       	: The node to translate.
$activeSpace    : Allows to know if the escape characters must be 
				  displayed or not.
$newLine    	: Allows to know If one is placed on a new line

Returns : A twiki syntax chain of this given node.
=cut
sub nodeProcess {
    my($node, $activeSpace, $newLine)= @_;
    
    my $sNode = uc($node->tag());
	my @associatedWikiTagTab = ();
    if($sNode eq "H1") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL1, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif ($sNode eq "H2") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL2, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif ($sNode eq "H3") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL3, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif ($sNode eq "H4") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL4, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif ($sNode eq "H5") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL5, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif ($sNode eq "H6") {
        return &simpleTagProcess($node, $TWIKI_TITLE_LEVEL6, $TWIKI_TITLE_ENDINGTAG, $FALSE, $newLine, $FALSE);
    } elsif (($sNode eq "P") || ($sNode eq "BLOCKQUOTE")) {
         return &simpleTagProcess($node, "\n\n", "\n\n",$activeSpace, $newLine, $TRUE);
    } elsif ($sNode eq "HR") {
    	return &simpleTagProcess($node, $TWIKI_SEPARATOR, "",$activeSpace, $newLine, $TRUE);
    } elsif ($sNode eq "BR") {
    	return &simpleTagProcess($node, $TWIKI_NEXT_LINE, "",$activeSpace, $newLine, $TRUE);
    } elsif ($sNode eq "PRE") {
        return &preformattedProcess($node, $TWIKI_VERBATIM_OPENINGTAG, $TWIKI_VERBATIM_CLOSINGTAG, $newLine);
    } elsif (($sNode eq "B") || ($sNode eq "STRONG")){
    	@associatedWikiTagTab = (["I", $TWIKI_BOLD_ITALIC], ["EM", $TWIKI_BOLD_ITALIC], ["CODE", $TWIKI_BOLD_FIXEDFONT]);
        return &styleProcess($node, $TWIKI_BOLD, @associatedWikiTagTab, $newLine);
    } elsif (($sNode eq "I") || ($sNode eq "EM")){
    	@associatedWikiTagTab = (["B", $TWIKI_BOLD_ITALIC], ["STRONG", $TWIKI_BOLD_ITALIC]);
        return &styleProcess($node, $TWIKI_ITALIC, @associatedWikiTagTab, $newLine);        
    } elsif ($sNode eq "CODE") {
    	 @associatedWikiTagTab = (["B", $TWIKI_BOLD_FIXEDFONT], ["STRONG", $TWIKI_BOLD_FIXEDFONT]);
         return &styleProcess($node, $TWIKI_FIXEDFONT, @associatedWikiTagTab, $newLine);   
         
    } elsif ($sNode eq "UL") {
      return &listProcess($node, $TWIKI_LIST_TAG, $TWIKI_LIST_INDENTSTEP, $newLine);
    } elsif ($sNode eq "OL") {
        return &listProcess($node, $TWIKI_ORDERLIST_TAG, $TWIKI_LIST_INDENTSTEP, $newLine);
   	} elsif ($sNode eq "DL") {
        return &definitionListProcess($node, $TWIKI_DEFINITIONLIST_TAG, $newLine);
  	} elsif ($sNode eq "A") {
        return &linkProcess($node);
  	} elsif ($sNode eq "TABLE") {
        return &tableProcess($node, $newLine);
   	}

    return &HtmlTagProcess($node, $activeSpace, $newLine);
}

################################ DONE ################################
=pod
---++ HtmlTagProcess((Node node,  boolean activeSpace, boolean newLine)
Used to process the html tags which can't be translated.

$node       	: The node to translate.
$activeSpace    : Allows to know if the escape characters must be 
				  displayed or not.
$newLine    	: Allows to know If one is placed on a new line

Returns : A twiki syntax chain of this given node.
=cut
sub HtmlTagProcess{
    my ($node, $activeSpace, $newLine) = @_;
    my $sNode = (!$newLine)?"\n".$MARGIN:"";

    my $sNodeName = uc($node->tag());
  
    if($sNodeName ne "HTML" && $sNodeName ne "HEAD" && $sNodeName ne "BODY") {
        $sNode .= "<".$sNodeName;

        my @attrs = $node->all_external_attr_names();
        if(length(@attrs)>0){
            foreach my $attr (@attrs){
                my $sAttribut = " ".$attr."=\"".$node->attr($attr)."\"";
                $sNode .= $sAttribut;
            }
        }
      
        $sNode .= (!$activeSpace)?">":">\n".$MARGIN;
      
        $sNode .= &getChildrenProcess($node, $activeSpace, $activeSpace);

        # closing tag.
        my $sClosingTag = "</".$sNodeName;
        $sClosingTag .= (!$activeSpace)?">":">\n".$MARGIN;
        $sNode .= $sClosingTag;
    }else {   
        $sNode .= &getChildrenProcess($node, $activeSpace, $activeSpace);
    }
    return $sNode;
}

################################ DONE ################################
=pod
---++ getChildrenProcess($node, $activeSpace, $newLine)
Allows to process the children nodes of $node.

$node       	: The node to translate.
$activeSpace    : Allows to know if the escape characters must be 
				  displayed or not.
$newLine    	: Allows to know If one is placed on a new line

@returns : A twiki syntax chain of this given children node.
=cut
sub getChildrenProcess{
    my($node, $activeSpace, $newLine) = @_;
    my $sNode = "";
    my @children = $node->content_list();
  
    if(length(@children)>0){
        my $bNewLine = $newLine;
        foreach my $child (@children){
            $sNode .= processTranslate($child, $activeSpace, $bNewLine);
            $bNewLine = &isNewLine($sNode);
        }
    } 
    return $sNode;
}

################################ DONE ################################
=pod
---++ simpleTagProcess($$node, $beginningWikiTag, $endingWikiTag,$activeSpace, $newLine, $bOptionalEndingTag)
Allows to translate the simple html tags.

$node       			: The node to translate.
$beginningTitleTag   	: The beginning twiki tag which replaces the beginning html title tag. 
$endingTitleTag			: The ending twiki tag which replaces the ending html title tag.
$newLine    			: Allows to know If one is placed on a new line
$bOptionalEndingTag		: If $bOptionalEndingTag equals $TRUE and if no children exists for $node,
						  then $endingTitleTag is not added.

@returns : A twiki syntax chain of this given node.
=cut
sub simpleTagProcess{
    my($node, $beginningWikiTag, $endingWikiTag, $activeSpace, $newLine, $bOptionalEndingTag) = @_;
    my $sNode = (!$newLine)?"\n".$MARGIN.$beginningWikiTag:$beginningWikiTag;
    my $sTempNode = $sNode;
    
    $sNode .= &getChildrenProcess($node, $activeSpace, $TRUE);
	$sNode .= ($bOptionalEndingTag)?($sTempNode ne $sNode)?$endingWikiTag:"" : $endingWikiTag;

    return $sNode;
}

################################ DONE ################################
=pod
---++ composedTagProcess($node, $sDefaultWikiTag, @associatedWikiTagTab, $activeSpace, $newLine)
Allows to translate the composed tags.

$node       			: The node to translate.
$sDefaultWikiTag		: The default tag which uses to encapsule $node if
						  if no tag containing in @associatedWikiTagTab follows it.
@associatedWikiTagTab	: A table which contains all the composed tags and the wiki tag 
						  which has to be used.						  
$activeSpace    		: Allows to know if the escape characters must be 
				  		  displayed or not.
$newLine    			: Allows to know If one is placed on a new line

@returns : A twiki syntax chain of this given node.
=cut
sub styleProcess{
    my($node, $sDefaultWikiTag, @associatedWikiTagTab, $newLine) = @_;
    my $sNode = ""; # ($activeSpace && !$newLine) ? "\n".$MARGIN : "";
    my $sWikiTag = $sDefaultWikiTag;
    
    my @children = $node->content_list();
  
    if(length(@children)>0){
        if(length(@children) == 1 && ref($children[0])) {
            if (ref($children[0])){
            	for(my $i=0; $i <=($#associatedWikiTagTab); $i++){
            		if(length($associatedWikiTagTab[$i]) >= 2){	
            			if(uc($children[0]->tag()) eq uc($associatedWikiTagTab[$i][0])) {
                			$sWikiTag = $associatedWikiTagTab[$i][1];
                			$node = $children[0];
                			last;
                		}
                	}
                }
            }
        }
        $sNode .= " ".$sWikiTag.&trimChain(&getChildrenProcess($node, $FALSE, $FALSE)).$sWikiTag." ";
    }
    return $sNode;
}

################################ DONE ################################
=pod
---++ preformattedProcess($node, $newLine)
Used to translate the html tag 'PRE'.

$node       	: The node to translate.
$newLine    	: Allows to know If one is placed on a new line

@returns : A twiki syntax chain of this given node.
=cut
sub preformattedProcess{
    my($node, $beginningWikiTag, $endingWikiTag, $newLine) = @_;
    my $sNode = (!$newLine) ? "\n".$MARGIN : "";
    $sNode .= $beginningWikiTag;
    my $sNodeValue = &getChildrenProcess($node, $TRUE, $TRUE);
    $sNode .= (&isNewLine($sNode) || $sNodeValue =~ /^\n/) ?"":"\n".$MARGIN;
    $sNode .= (!&isNewLine($sNode)) ? $sNodeValue."\n".$MARGIN : $sNodeValue;
    $sNode .= $endingWikiTag;
    $sNode .= (!&isNewLine($sNode))?"\n".$MARGIN:"";
    return $sNode;
}

#****************************************************************************#
#**************************** LIST PROCESS **********************************#
#****************************************************************************#

############################# DONE AND OPTIMIZED #############################
=pod
---++ listProcess($node, $sWikiTag, $newLine)
Used to translate the list html tag (tag: UL).

$node       	: The node to translate.
$sWikiTag  		: The twiki tag used to create the bullets.
$newLine    	: Allows to know If one is placed on a new line

@returns : A twiki syntax chain of this given node.
=cut
sub listProcess{
    my($node, $sWikiTag, $listIndentStep, $newLine) = @_;
    my $sNode = (!$newLine || ($MARGIN eq ""))?"\n":"";
    
    my @children = $node->content_list();
    if(length(@children)>0){
        my $OLDMARGIN = $MARGIN;
        $MARGIN = $MARGIN.$listIndentStep;
        
        my $bNewLine = (&isNewLine($sNode) || $newLine);
        
        foreach my $child (@children){
        
         	if(ref($child) && uc($child->tag()) eq "LI"){	
         
				my @childrenListItem = $child->content_list();	
				if(length(@childrenListItem)>0){
				
					$sNode .= (!$bNewLine) ? "\n".$MARGIN.$sWikiTag." " : $MARGIN.$sWikiTag." ";
					
					foreach my $childListItem (@childrenListItem){
				   		my $sNodeValue = &trimChain(&processTranslate($childListItem, $FALSE, $bNewLine));
				   		$sNode .= $sNodeValue;
				   	}
    			}
            } else{     
                	$sNode .= &processTranslate($child, $FALSE, $bNewLine);
            }
            $bNewLine = &isNewLine($sNode);
        }
        $sNode .=($MARGIN eq $listIndentStep)?"\n":"";
        
        $MARGIN = $OLDMARGIN;
    }
    return $sNode;
}

############################# DONE AND OPTIMIZED #############################
=pod
---++ definitionListProcess($node, $newLine)
Used to translate the definition list html tag (tag DL).

$node       	: The node to translate.
$sWikiTag  	: The twiki tag used to create the list definition.
$newLine    	: Allows to know If one is placed on a new line.

@returns : A twiki syntax chain of this given node.
=cut 
sub definitionListProcess{
    my($node, $sWikiTag, $newLine) = @_;
    
    my $sNode = "";
    
    my @children = $node->content_list();
    if(length(@children)>0){
      my $bNewLine = $newLine;
     
      foreach my $child (@children){
        if (ref($child) && uc($child->tag()) eq "DT") {
          $sNode .= (!$bNewLine) ? "\n".$MARGIN : "";
          $sNode .= $sWikiTag;
          my $sNoveValue = &getChildrenProcess($child, $FALSE, $bNewLine);
          $sNoveValue =~ s/\n/ /g;
          $sNode .= &trimChain($sNoveValue);
        }
        
        if (ref($child) &&  uc($child->tag()) eq "DD") {
        	my $sNoveValue = &getChildrenProcess($child, $FALSE, $bNewLine);
          	$sNoveValue =~ s/\n/ /g;
          	$sNode .= ": ".&trimChain($sNoveValue);
          	$sNode .= (!&isNewLine($sNode)) ? "\n".$MARGIN : "";
        }
        $bNewLine = &isNewLine($sNode);
      }
    }
    return $sNode;
}
  
############################# DONE AND OPTIMIZED #############################
=pod
---++ linkProcess($node)
Used to translate the hyperlink html tag.

$node       	: The node to translate.

@returns : A twiki syntax chain of this given node.
=cut
sub linkProcess {
    my ($node) = @_;
    my $sNode = "";
    my $sNodeValue = &getChildrenProcess($node, $FALSE, $FALSE);
    my @attrs = $node->all_external_attr_names();   

    $sNodeValue =~ s/([\s]+|$WIKIWORD_PROTECTION_TAG)/ /g;
    $sNodeValue = &trimChain($sNodeValue);
    if(length(@attrs)>0){
        my $nHref  = ($node->attr("href")  || ""); $nHref =~ s/([\s]+)/ /g;
        my $nName  = ($node->attr("name")  || ""); $nName =~s/([\s]+)/ /g;
        my $nClass = ($node->attr("class") || "");
        if ($nHref ne "") {
            # TwikiWords case
            if ((($nHref =~ /^([A-Z]+[a-z]+[A-Z]([a-zA-Z]*?))$/) || ($nClass ne "" && $nClass eq $WIKIWORDCLASS)) && 
            	($sNodeValue eq "" || $nHref eq $sNodeValue)){
                    return $nHref;
            }
            $sNode = "[$nHref]"; 
        } elsif(($nName ne "")) {
            $nName = ($nName =~ /^\#/) ? $nName : "#$nName";
            $sNode .= $nName." ".$sNodeValue;
            return $sNode;
        }     
		if ($sNodeValue ne "") {
			# Allows the Wikiword create by <A>WikiWord</A>
			$sNode = ($sNode eq "" && $sNodeValue =~ /^([A-Z]+[a-z]+[A-Z]([a-zA-Z]*?))$/)? $sNodeValue : "[".$sNode."[".$sNodeValue."]]";
		}else{
			$sNode = "[$sNode]";
		}
    }
    return $sNode;
}

#****************************************************************************#
#*************************** TABLE PROCESS **********************************#
#****************************************************************************#

################################ DONE ################################
=pod
---++ tableProcess($node, $newLine)
Used to translate the table html tag.

$node       	: The node to translate.
$newLine    	: Allows to know If one is placed on a new line.

@returns : A twiki syntax chain of this given node.
=cut
sub tableProcess{
    my($node, $newLine) = @_;
    my $sNode = (!$newLine) ? "\n".$MARGIN : "";
    
    if (&isTwikiTable($node)) {
        my @children = $node->content_list();
        if(length(@children)>0){   
        	foreach my $child (@children){
                if(ref($child) && uc($child->tag())  eq "TBODY") {
                        $sNode .= &tableProcess($child, $newLine);
                } elsif(ref($child) && uc($child->tag())  eq "TR") {
                    $sNode .= &trProcess($child);
                }
            }
        }
    } else {
      	$sNode = &HtmlTagProcess($node, $TRUE, $newLine);
    }
    return $sNode."\n".$MARGIN; # "\n" : To avoid to stick two twiki tables
}

################################ DONE ################################
=pod
---++ isTwikiTable($node) {
Allows to know if the table containing in $node is a twiki table and
must be translated or not.

$node       	: The node to translate.

@return $TRUE if the table is a well twiki table. $FALSE otherwise.
=cut
sub isTwikiTable{
    my($node) = @_;
    
    if (&nodeNewLineChildren($node)) {
      return $FALSE;
    }
    
    my $bTwiki = $TRUE;
    
    my @attrs = $node->all_external_attr_names();
    if((length(@attrs) > 0) && !(uc($node->tag()) eq "TBODY")){
    	my $nBorder = ($node->attr("border") || "");  
        $bTwiki = (($nBorder eq "") || (($nBorder =~ /[0-9]+/) && $nBorder!=1)) ? $FALSE : $TRUE;
    }
    
    if ($bTwiki) {
		my @tableChildren = $node->content_list();
        if(length(@tableChildren)>0){   
        	foreach my $tableChild (@tableChildren){ 
        	 	if(ref($tableChild) && uc($tableChild->tag) eq "TR") {
        	   		my @trChildren = $tableChild->content_list();
        	 
        	       	if(length(@trChildren)>0){   
        	         	foreach my $trChild (@trChildren){
        	           		if(ref($trChild) && ((uc($trChild->tag()) eq "TD") || (uc($trChild->tag()) eq "TH"))) {
        	                	my @attrsChildren = $trChild->all_external_attr_names();
        	                    if(length(@attrsChildren)>0) {
        	                     	my $nRowspan = ($trChild->attr("rowspan") || ""); 
        	                     	$bTwiki = (($nRowspan ne "") && ($nRowspan =~/[0-9]+/ && $nRowspan != 1)) ? $FALSE : $TRUE;
        	                   	}
        	             	}
        	                if (!$bTwiki){last;}
        	          	}
        	      	}
        	  	}else{
        	      	if(ref($tableChild) && uc($tableChild->tag()) eq "TBODY") {
       	          		$bTwiki = &isTwikiTable($tableChild);
               		}
         		}
            	if (!$bTwiki){last;}
   			}
 		}
 	}
    return $bTwiki;
}

################################ DONE ################################
=pod
---++ trProcess($node)
Used to process the TR html tag.

$node       	: The node to translate.

@returns : A twiki syntax chain of this given node.
=cut
sub trProcess{
    my($node) = @_; 
    
    my $sNode = "";
    my @children = $node->content_list();
    
    if(length(@children)>0){   
        foreach my $child (@children){
        	if(ref($child) && ((uc($child->tag()) eq "TD") || (uc($child->tag()) eq "TH"))) {
        		$sNode .= &tdProcess($child, (uc($child->tag()) eq "TH"));
            }
        }
        $sNode .= "|\n".$MARGIN;
    }
    return $sNode;
}

################################ DONE ################################
=pod
---++ tdProcess($node)
Used to process the TD or TH html tag.

$node       	: The node to translate.
$tableHeaders	: $TRUE if the tag is a Table header tag (TH)

@returns : A twiki syntax chain of this given node.
=cut
sub tdProcess{
	my($node, $tableHeaders) = @_;
    
    my $sNode = "";  
    my $sStartLine = "  ";
    my $sEndLine = "  ";
    my $sColspan = "";
    my @attrs = $node->all_external_attr_names();
    
    if(length(@attrs)>0){
    	my $nColSpan = ($node->attr("colspan") || "");  
        my $nAlign = ($node->attr("align") || "");  
        
        if($nColSpan ne "") {
        	if($nColSpan =~ /[0-9]+/){
				for (my $j = 1; $j < $nColSpan; $j++) {
					$sColspan .= "|";
				}
      		}else{
      			print "ERROR :: TDPROCESS => NUMBER FORMAT EXCEPTION";            # TODO To see what to do...
      		}
      	}
      	
		if ($nAlign ne "") {
			if (uc($nAlign) eq "RIGHT") {
				$sEndLine = "";
			}elsif (uc($nAlign) eq "LEFT") {
				$sStartLine = "";
			}
		}
  	}
    $sNode .= "|".$sStartLine;
    my $sCellText = &trimChain(&getChildrenProcess($node, $FALSE, $FALSE));
    if($tableHeaders){
    	$sNode .= ($sStartLine =~ / $/)?$TWIKI_BOLD:" ".$TWIKI_BOLD;
    	$sNode .= $sCellText;
    	$sNode .= ($sEndLine =~ /^ /)?$TWIKI_BOLD:$TWIKI_BOLD." ";
    	$sNode .= $sEndLine.$sColspan;
    }else{
    	$sNode .= $sCellText.$sEndLine.$sColspan;
    }
    return $sNode;
  }


=pod
---++ nodeNewLine($node)
ADDED by Colas Nahaboo

$node       	: The node to check.

@return $TRUE if the resulting TWiki syntax would force a newline
=cut 
sub nodeNewLine{
    my($node) = @_;
    
    my $sNode = (ref($node))?uc($node->tag()):"";

    if ($sNode eq "H1" || $sNode eq "H2" || $sNode eq "H3" || 
        $sNode eq "H4" || $sNode eq "H5" || $sNode eq "H6" ||
        $sNode eq "PRE"|| $sNode eq "P"  || $sNode eq "BLOCKQUOTE"||
        $sNode eq "UL" || $sNode eq "OL" || $sNode eq "DL" ||
        $sNode eq "HR" || $sNode eq "BR" || $sNode eq "TABLE"){
      return $TRUE;
    } else {
      # Other, just let the children decide
      return &nodeNewLineChildren($node);
    }
  }


=pod
---++ nodeNewLineChildren($node)
ADDED by Colas Nahaboo

$node       	: The node to check.

@return $TRUE if the resulting TWiki syntax would force a newline
=cut 
sub nodeNewLineChildren{
    my($node) = @_;
    
    my @children = (ref($node))?$node->content_list():();
    if(length(@children)>0){   
        foreach my $child (@children){
            if (&nodeNewLine($child)) {
                return $TRUE;
            }
        }
    }
    return $FALSE;
}


# TO DELETE!!!!
sub debug{
  if($DEBUG_MODE){
    print @_, "\n";  
  }
}