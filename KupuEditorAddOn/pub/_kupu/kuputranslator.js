/*****************************************************************************
 * 
 * XHTML/TWikiML Translator 1.06
 * Copyright (C) 2003 Frederic Luddeni
 *  
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 *****************************************************************************/

/*****************************************************************************
 * 
 * TWiki KupuEditorAddOn add-on for TWiki
 * Copyright (C) 2004 Damien Mandrioli and Romain Raugi
 *  
 * Modifications done for TWiki KupuEditorAddOn :
 * - 2004-10-09 - Translated from Java to JavaScript
 * - 2004-10-09 - KupuTool format
 * - 2004-10-09 - Comments
 * - 2004-10-09 - hasChildNodeNamed function and calls
 * - 2004-10-09 - Variables management
 * - 2004-10-24 - Permissions management  
 * - 2004-10-09 - "<BR>"s management 
 * - 2004-10-10 - HtmlToTwikiTranslatorTool.nopsProcess
 * - 2004-10-10 - Most of TWikiML to XHTML translator has been modified :
 *                - TwikiToHtmlTranslatorTool regexps, functions ...
 * - 2004-10-10 - TODO : Definition lists (TWikiML to HTML)
 * - 2004-10-10 - TODO : CODE & VERBATIM management (TWikiML to HTML)
 * - 2004-10-10 - TODO : HtmlToTwikiTranslatorTool.nopProcess
 *  
 *****************************************************************************/

function HtmlToTwikiTranslatorTool() {
  /* TWiki KupuEditorAddOn HTML to TWikiML translation */
  this.viewPermissionsMetaName = 'view_permissions';
  this.changePermissionsMetaName = 'change_permissions';
  this.internalLinkClass = 'INTERNAL_LINK';
  this.variableClass = 'VARIABLE';

  this.trim = function(text) {
    /* Java trim() function - like */
    return text.replace(/^\s*(.*)/, "$1").replace(/(.*?)\s*$/, "$1");
  };
  
  this.isNewLine = function(text) {
    /* test if last character is end of line */
    return (text.charAt(text.length - 1) == '\n');
  };
  
  this.specialCharProcess = function(sText) {
    /* manage special characters */
    sText = sText.replace(/é/g, "&eacute;");
    sText = sText.replace(/è/g, "&eacute;");
    sText = sText.replace(/è/g, "&egrave;");
    sText = sText.replace(/ê/g, "&ecirc;");
    sText = sText.replace(/à/g, "&agrave;");
    sText = sText.replace(/â/g, "&acirc;");
    sText = sText.replace(/ç/g, "&ccedil;");
    sText = sText.replace(/î/g, "&icirc;");
    sText = sText.replace(/ô/g, "&ocirc;");
    sText = sText.replace(/ù/g, "&ugrave;");
    sText = sText.replace(/û/g, "&ucirc;");
    return sText;
  };
  
  this.translate = function(node) {
    /* translation main procedure */
    var body = node.getElementsByTagName('body')[0];
    var text = this.processTranslate(body, true, true);
    // permissions
    var metaTags = node.getElementsByTagName("meta");
    var viewPerms = metaTags.namedItem(this.viewPermissionsMetaName).attributes.getNamedItem("content");
    var changePerms = metaTags.namedItem(this.changePermissionsMetaName).attributes.getNamedItem("content");
    if (viewPerms && viewPerms.nodeValue != '') {
      text += "\n   * SETALLOWTOPICVIEW = " + viewPerms.nodeValue;
    };
    if (changePerms && changePerms.nodeValue != '') {
      text += "\n   * SETALLOWTOPICCHANGE = " + changePerms.nodeValue;
    };
    // WikiWords
    text = text.replace(/\[\[([^\]]+)\]\[\1\]\]/gi, "$1");
    // spaces at the beginning
    text = text.replace(/^[\s]*/, "");
    return text;
  };
  
  this.processTranslate = function(node, activeSpace, newLine) {
    /* process main translation */
    var sText = "";
    if (node == null) return "";
      var type = node.nodeType;
      switch (type) {
      case 1:
        // element node
        sText = this.nodeProcess(node, activeSpace, newLine);
        break;
      case 3:
        // text node
        var sNodeValue = node.nodeValue;
        sNodeValue = this.specialCharProcess(sNodeValue);
        if (!activeSpace) {
          sNodeValue = sNodeValue.replace(/([ ]+|[ \t\n\f\r])/g, ' ');
        };
        var trimed = this.trim(sNodeValue);
        if (trimed != "\n" && trimed != "") {
          sText = sNodeValue;
        };
        break;
    };
    return sText;
  };
    
  this.nodeProcess = function(node, activeSpace, newLine) {
    /* process node element */
    var sNode = node.nodeName;
    if (sNode.toUpperCase() == "H1") {
      return this.titleProcess(node, "---+", newLine);
    }
    else if (sNode.toUpperCase() == "H2") {
      return this.titleProcess(node, "---++", newLine);
    }
    else if (sNode.toUpperCase() == "H3") {
      return this.titleProcess(node, "---+++", newLine);
    }
    else if (sNode.toUpperCase() == "H4") {
      return this.titleProcess(node, "---++++", newLine);
    }
    else if (sNode.toUpperCase() == "H5") {
      return this.titleProcess(node, "---+++++", newLine);
    }
    else if (sNode.toUpperCase() == "H6") {
      return this.titleProcess(node, "---++++++", newLine);
    }
    else if (sNode.toUpperCase() == "B" ||
             sNode.toUpperCase() == "STRONG") {
      return this.styleProcess(node, sNode.toUpperCase(), activeSpace, newLine);
    }
    else if (sNode.toUpperCase() == "I" || sNode.toUpperCase() == "EM") {
      return this.styleProcess(node, sNode.toUpperCase(), activeSpace, newLine);
    }
    else if (sNode.toUpperCase() == "CODE") {
      return this.fixedFontProcess(node, activeSpace, newLine);
    }
    else if (sNode.toUpperCase() == "PRE") {
      return this.verbatimProcess(node, newLine);
    }
    else if (sNode.toUpperCase() == "P" ||
             sNode.toUpperCase() == "BLOCKQUOTE") {
      return this.paragraphProcess(node, newLine);
    }
    else if (sNode.toUpperCase() == "UL") {
      return this.listProcess(node, "*", 1, newLine);
    }
    else if (sNode.toUpperCase() == "OL") {
      //return orderListProcess(node, newLine);
      return this.listProcess(node, "1", 1, newLine);;
    }
    else if (sNode.toUpperCase() == "DL") {
      return this.definitionListProcess(node, newLine);
    }
    else if (sNode.toUpperCase() == "A") {
      return this.linkProcess(node);
    }
    else if (sNode.toUpperCase() == "SPAN") {
      return this.variablesProcess(node, activeSpace, newLine);
    }
    else if (sNode.toUpperCase() == "TABLE") {
      return this.tableProcess(node, newLine);
    }
    else if (sNode.toUpperCase() == "HR") {
      return this.simpleHtmlTagProcess("---", activeSpace, newLine);
    }
    else if (sNode.toUpperCase() == "BR") {
      return this.simpleHtmlTagProcess("\n", true, newLine);
    }
    else {
      sNode = this.htmlTagProcess(node, activeSpace, newLine);
    };
    return sNode;
  };
    
  this.htmlTagProcess = function(node, activeSpace, newLine) {
    /* unknown html tags */
    var sNode = (activeSpace && !newLine) ? "\n" : "";
    var sNameNode = node.nodeName;
    if (sNameNode.toUpperCase() != "BODY") {
      sNode += "<" + sNameNode.toLowerCase();
      var attrs = node.attributes;
      for (var i = 0; i < attrs.length; i++) {
        if ( attrs.item(i).nodeValue && attrs.item(i).nodeValue != "" ) {
          var sAttribut = " " + attrs.item(i).nodeName + "=\"" +
                          attrs.item(i).nodeValue + "\"";
          sNode += sAttribut;
        };
      };
      sNode += (!activeSpace) ? ">" : ">\n";
      sNode += this.getChildrenProcess(node, activeSpace, activeSpace);
      // closing tag.
      var sClosingTag = "</" + sNameNode.toLowerCase();
      sClosingTag += (!activeSpace) ? ">" : ">\n";
      sNode += sClosingTag;
    }
    else {
      sNode += this.getChildrenProcess(node, activeSpace, activeSpace);
    };
    return sNode;
  };
  
  this.getChildrenProcess = function(node, activeSpace, newLine) {
    /* process children of a node */
    var sNode = (activeSpace && !newLine) ? "\n" : "";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      var bNewLine = newLine;
      for (var i = 0; i < len; i++) {
        //if (node.getNodeName().equalsIgnoreCase("body"))
        sNode += this.processTranslate(children.item(i), activeSpace, bNewLine);
        bNewLine = this.isNewLine(sNode);
      };
    };
    return sNode;
  };
  
  this.variablesProcess = function(node, activeSpace, newLine) {
    /* process variables */
    var attrs = node.attributes;
    var cls = attrs.getNamedItem("class");
    var clsVal = (cls) ? cls.nodeValue : "";
    if (clsVal.toUpperCase() ==  this.variableClass) {
      return "%" + this.trim(this.getChildrenProcess(node, activeSpace, newLine)) + "%";
    } else {
      return this.htmlTagProcess(node, activeSpace, newLine);
    };
  };
  
  this.titleProcess = function(node, tagTitle, newLine) {
    /* process titles */
    var sNode = tagTitle;
    sNode += this.getChildrenProcess(node, false, newLine);
    return (!newLine) ? "\n" + sNode + "\n" : sNode + "\n";
  };
  
  this.linkProcess = function(node) {
    /* process links */
    var sNode = "";
    var bContinue = true, SimpleTwikiWord = false;
    var attrs = node.attributes;
    var sNodeValue = "";
    sNodeValue += this.getChildrenProcess(node, false, false);
    sNodeValue = this.trim(sNodeValue.replace(/([ ]+|[ \t\n\f\r]|<nop>)/g, " "));
    if (attrs != null) {
      var nHref = attrs.getNamedItem("href");
      var nName = attrs.getNamedItem("name");
      var nClass = attrs.getNamedItem("class");
      if (nHref != null) {
        var sTmpUrl = nHref.nodeValue.replace(/([ ]+|[ \t\n\f\r])/g, " ");

        // WikiWords case.
        if (nClass != null && (nClass.nodeValue.toUpperCase() == this.internalLinkClass)) {
          sTmpUrl = sTmpUrl.replace(/(.*\/(?=[^\/]+$))/, "");
          /** @todo verifier si href est un TwikiWord et si dans ce cas href=name*/
          if (sTmpUrl.toUpperCase() == sNodeValue.toUpperCase()) {
            sNode = sTmpUrl;
            SimpleTwikiWord = true;
          };
          bContinue = false;
        };
        if (!SimpleTwikiWord)
          sNode = "[" + sTmpUrl + "]";
      }
      else if (nName != null && bContinue) {
        var sName = nName.nodeValue.replace(/([ ]+|[ \t\n\f\r])/g, " ");
        sName = (sName.charAt(0) != '#') ? "#" + sName : sName;
        sNode += sName + " " + this.getChildrenProcess(node, false, false);
        return sNode;
      };
      // verifier si La valeur du lien doit être inserée pour completer le lien.
      if (sNodeValue != "" && !SimpleTwikiWord) {
        if (sNode.toUpperCase() != sNodeValue.toUpperCase()) {
          sNode = "[" + sNode + "[" + sNodeValue + "]]";
        }
        else {
          sNode = "[" + sNode + "]";
        };
      };
    };
    return sNode;
  };

  this.paragraphProcess = function(node, newLine) {
    /* process paragraphs */
    var sNode = (newLine) ? "\n" : "\n\n";
    sNode += this.getChildrenProcess(node, true, true);
    sNode += (!this.isNewLine(sNode)) ? "\n" : "";
    return sNode;
  };
  
  this.simpleHtmlTagProcess = function(twikiTag, activeSpace, newLine) {
    /* process single tags */
    var sNode = (activeSpace && !newLine) ? "\n" : "";
    sNode += twikiTag;
    sNode += (activeSpace) ? "\n" : "";
    return sNode;
  };
  
  this.verbatimProcess = function(node, newLine) {
    /* process verbatim code */
    var sNode = (!newLine) ? "\n" : "";
    sNode += "<verbatim>\n";
    sNode += this.getChildrenProcess(node, true, true);
    sNode += (!this.isNewLine(sNode)) ? "\n" : "";
    sNode += "</verbatim>\n";
    return sNode;
  };
  
  this.fixedFontProcess = function(node, activeSpace, newLine) {
    /* process fixed font elements */
    var sNode = (activeSpace && !newLine) ? "\n" : "";
    var children = node.childNodes;
    if (children != null) {
      if (children.length == 1 &&
         (children.item(0).nodeName.toUpperCase() == "B" ||
         children.item(0).nodeName.toUpperCase() == "STRONG")) {
        sNode = " ==";
        sNode += this.getChildrenProcess(children.item(0), false, false);
        sNode += "== ";
      }
      else {
        sNode = " =";
        sNode += this.getChildrenProcess(node, false, false);
        sNode += "= ";
      };
    };
    return sNode;
  };
  
  this.styleProcess = function(node, sTag, activeSpace, newLine) {
    /* process styled blocks */
    var sNode = (activeSpace && !newLine) ? "\n" : "";
    var sOtherTag = ""; // The other tag which allow to use the twiki tag '__'.
    var sOtherTag2 = "";
    var sTwikiTag = "";
    var verifFixedFontProcess = false;
    if (sTag.toUpperCase() == "B" || sTag.toUpperCase() == "STRONG") {
      sOtherTag = "I";
      sOtherTag2 = "EM";
      sTwikiTag = "*";
      verifFixedFontProcess = true;
    }
    else {
      if (sTag.toUpperCase() == "I" || sTag.toUpperCase() == "EM") {
        sOtherTag = "B";
        sOtherTag2 = "STRONG";
        sTwikiTag = "_";
      }
      else {
        // nothing
      };
    };
    var children = node.childNodes;
    if (children != null) {
      if (children.length == 1) {
        if (children.item(0).nodeName.toUpperCase() == sOtherTag ||
            children.item(0).nodeName.toUpperCase() == sOtherTag2) {
          sTwikiTag = "__";
          node = children.item(0);
        }
        else {
          if (verifFixedFontProcess) {
            if (children.item(0).nodeName.toUpperCase() == "CODE") {
              sTwikiTag = "==";
              node = children.item(0);
            };
          };
        };
      ;}
      sNode = " " + sTwikiTag;
      sNode += this.getChildrenProcess(node, false, false);
      sNode += sTwikiTag + " ";
    };
    return sNode;
  };
  
  this.listProcess = function(node, sTwikiTag, niveau, newLine) {
    /* process lists */
    var sNode = "";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      var bNewLine = newLine;
      for (var i = 0; i < len; i++) {
        if (children.item(i).nodeName.toUpperCase() == "LI") {
          sNode += this.listeItemProcess(children.item(i), sTwikiTag, niveau, bNewLine);
        }
        else {
          sNode += this.processTranslate(children.item(i), false, bNewLine);
        };
        bNewLine = this.isNewLine(sNode);
      };
    };
    return sNode;
  };
  
  this.listeItemProcess = function(node, sTwikiTag, niveau, newLine) {
    /* process listitems */
    var sNode = "";
    for (var i = 0; i < niveau; ++i) {
      sNode = sNode + "   ";
    }
    sNode = (!newLine) ? "\n" + sNode + sTwikiTag + " " :
    sNode + sTwikiTag + " ";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      var bNewLine = (sNode.charAt(sNode.length - 1) == '\n');
      for (var i = 0; i < len; i++) {
        if (children.item(i).nodeName.toUpperCase() == "UL") {
          if (this.trim(sNode) == sTwikiTag) {
            sNode = this.listProcess(children.item(i), "*", niveau + 1, bNewLine);
          }
          else {
            sNode += this.listProcess(children.item(i), "*", niveau + 1, bNewLine);
          };
        }
        else if (children.item(i).nodeName.toUpperCase() == "OL") {
          if (this.trim(sNode) == sTwikiTag) {
            sNode = this.listProcess(children.item(i), "1", niveau + 1, bNewLine);
          }
          else {
            sNode += this.listProcess(children.item(i), "1", niveau + 1, bNewLine);
          };
        }
        else {
          sNode += this.processTranslate(children.item(i), false, false);
        };
        bNewLine = this.isNewLine(sNode);
      };
    };
    return sNode;
  };
  
  this.definitionListProcess = function(node, newLine) {
    /* process definition lists */
    var sNode = "";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      var bNewLine = newLine;
      for (var i = 0; i < len; i++) {
        if (children.item(i).nodeName.toUpperCase() == "DT") {
          sNode += (!bNewLine) ? "\n" : "";
          sNode += "   ";
          sNode += this.getChildrenProcess(children.item(i), false, bNewLine).replace(/ /g, "&nbsp;");
        };
        if (children.item(i).nodeName.toUpperCase() == "DD") {
          sNode += ": " + this.getChildrenProcess(children.item(i), false, bNewLine).replace(/ /g, "&nbsp;");
          sNode += (!this.isNewLine(sNode)) ? "\n" : "";
        };
        bNewLine = this.isNewLine(sNode);
      };
    };
    return sNode;
  };
  
  this.nopProcess = function(sNodeValue) {
    /* process nops */
    //var sText = "";
    //return sNodeValue.replace(/( |^)([A-Z]+[a-z]+\.)?([A-Z]+[a-z]+[A-Z][^ ,;$.?!<]*)/g, "$1<nop/>$2$3");
    return sNodeValue;
  };
  
  this.hasChildNodeNamed = function(node, nodeNames, depth) {
    /* test if a node has a specific (indirect or direct) child */
    var children = node.childNodes;
    var found = false;
    var k = 0;
    if (depth > 0) {
      while (k < nodeNames.length && ! found) {
        if (node.nodeName.toUpperCase() == nodeNames[k].toUpperCase()) {
          if (node.nodeName.toUpperCase() == "BR") {
            // last <br> -> doesn't mind
            var lastBRNode = node.parentNode.childNodes.item(node.parentNode.childNodes.length - 2);
            if (lastBRNode == node && node.nextSibling.nodeValue.match(/[ ]?/)) found = false;
            else found = true;
          } else
            found = true;
        };
        k++;
      };
      if (k <= nodeNames.length && found) return true;
    };
      
    if (children != null && children.length > 0) {
      var len = children.length;
      var toReturn = false;
      var i = 0;
      while (i < len && (!toReturn)) {
        toReturn = (toReturn || this.hasChildNodeNamed(children.item(i), nodeNames, depth + 1));
        i++;
      };
      return toReturn;
    } else {
      return false;
    };
  };
  
  this.isTwikiTable = function(node) {
    /* test if a table is twiki translatable */
    var bTwiki = true;
    var attrs = node.attributes;
    if (attrs != null && node.nodeName.toUpperCase() != "TBODY") {
      var nBorder = attrs.getNamedItem("border");
      bTwiki = (nBorder == null || parseInt(nBorder.nodeValue) != 1) ? false : true;
    };
    if (bTwiki) {
      // verify that there are no bullets, end_of_lines or tables in
      bTwiki = (this.hasChildNodeNamed(node, new Array("LI", "BR", "TABLE"), 0) == false);
      if (! bTwiki) return false;
    
      var tableChildren = node.childNodes;
      if (tableChildren != null) {
        for (var i = 0; i < tableChildren.length; i++) {
          if (tableChildren.item(i).nodeName.toUpperCase() == "TR") {
            var TrChildren = tableChildren.item(i).childNodes;
            if (TrChildren != null) {
              for (var j = 0; j < TrChildren.length; j++) {
                if (TrChildren.item(j).nodeName.toUpperCase() == "TD" ||
                    TrChildren.item(j).nodeName.toUpperCase() == "TH") {
                  var attrsChildren = TrChildren.item(j).attributes;
                  if (attrs != null) {
                    var nRowspan = attrsChildren.getNamedItem("rowspan");
                    bTwiki = (nRowspan != null && parseInt(nRowspan.nodeValue) != 1) ? false : true;
                  };
                };
                if (!bTwiki)
                  break;
              };
            };
          }
          else {
            if (tableChildren.item(i).nodeName.toUpperCase() == "TBODY") {
              bTwiki = this.isTwikiTable(tableChildren.item(i));
            };
          };
          if (!bTwiki)
            break;
        };
      };
    };
    return bTwiki;
  };
  
  this.tableProcess = function(node, newLine) {
    /* process tables */
    var sNode = (!newLine) ? "\n" : "";
    if (this.isTwikiTable(node)) {
      var children = node.childNodes;
      if (children != null) {
        var len = children.length;
        for (var i = 0; i < len; i++) {
          if (children.item(i).nodeName.toUpperCase() == "TBODY") {
            sNode += this.tableProcess(children.item(i), newLine);
          }
          else if (children.item(i).nodeName.toUpperCase() == "TR") {
            sNode += this.trProcess(children.item(i));
          };
        };
      };
    }
    else {
      sNode = this.htmlTagProcess(node, true, newLine);
    };
    return sNode + "\n"; // "\n" : pour éviter de coller deux tableaux
  };
  
  this.trProcess = function(node) {
    /* process line table */
    var sNode = "";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      for (var i = 0; i < len; i++) {
        if (children.item(i).nodeName.toUpperCase() == "TD" ||
            children.item(i).nodeName.toUpperCase() == "TH") {
          sNode += this.tdProcess(children.item(i));
        };
      };
      sNode += "|\n";
    };
    return sNode;
  };
  
  this.tdProcess = function(node) {
    /* process table cell */
    var sNode = "";
    var sStartLine = "  ";
    var sEndLine = "  ";
    var sColspan = "";
    var attrs = node.attributes;
    if (attrs != null) {
      var nColSpan = attrs.getNamedItem("colspan");
      var nAlign = attrs.getNamedItem("align");
      if (nColSpan != null) {
        try {
          var iNbCols = parseInt(nColSpan.nodeValue);
          for (var j = 1; j < iNbCols; j++) {
            sColspan += "|";
          };
        }
        catch (ex) {
          // nothing
        };
      }
      else {
        if (nAlign != null) {
          var sAlignType = nAlign.nodeValue;
          if (sAlignType.toUpperCase() == "RIGHT") {
            sEndLine = "";
          }
          else if (sAlignType.toUpperCase() == "LEFT") {
            sStartLine = "";
          };
        };
      };
    };
    sNode += "|" + sStartLine + this.trim(this.getChildrenProcess(node, false, false)) + sEndLine + sColspan;
    return sNode;
  };
  
};

HtmlToTwikiTranslatorTool.prototype = new KupuTool;

function TwikiToHtmlTranslatorTool() {
  /* TWiki KupuEditorAddOn TWikiML to HTML translation */
  this.viewPerms = '';
  this.changePerms = '';
  this.internalLinkClass = 'INTERNAL_LINK';
  this.variableClass = 'VARIABLE';

  this.trim = function(text) {
    /* Java trim() function - like */
    return text.replace(/^\s*(.*)/, "$1").replace(/(.*?)\s*$/, "$1");
  };
  
  this.translate = function(text) {
    /* translation main procedure */
    var sTextBis = text.split("\n");
    var array = new Array();
    for (var i = 0; i < sTextBis.length; ++i) {
      array.push(sTextBis[i]);
    };
    array = this.translateArray(array);
    sText = "";
    for (var i = 0; i < array.length; ++i) {
      sText += array[i] + "\n";
    };
    return sText;
  };
  
  this.getViewPermissions = function() {
    /* return last retrieved view permissions */
    return this.viewPerms;
  };
  
  this.getChangePermissions = function() {
    /* return last retrieved change permissions */
    return this.changePerms;
  };
  
  this.translateArray = function(text) {
    /* translation subroutine */
    text = this.permissionsProcess(text);
    text = this.variablesProcess(text);
    text = this.titlesProcess(text);
    text = this.tablesProcess(text);
    text = this.listsProcess(text);
    text = this.orderListsProcess(text);
    text = this.stylesProcess(text);
    text = this.paragraphsProcess(text);
    //text = this.verbatimsProcess(text);
    text = this.separatorsProcess(text);
    //text = this.definitionListsProcess(text);
    text = this.linksProcess(text);
    text = this.nopsProcess(text);
    return text;
  };
  
  this.permissionsProcess = function(text) {
    /* process permissions */
    this.viewPerms = '';
    this.changePerms = '';
    var rExp1 = new RegExp("^(\t|[ ]{3})\\\*[ ]*SETALLOWTOPICVIEW[ ]*=[ ]*(.*)");
    var rExp2 = new RegExp("^(\t|[ ]{3})\\\*[ ]*SETALLOWTOPICCHANGE[ ]*=[ ]*(.*)");
    for (var i = 0; i < text.length; i++) {
      if (text[i].search(rExp1) != -1) this.viewPerms = RegExp.$2;
      if (text[i].search(rExp2) != -1) this.changePerms = RegExp.$2;
      text[i] = text[i].replace(rExp1, "");
      text[i] = text[i].replace(rExp2, "");
    };
    return text;
  };
  
  this.variablesProcess = function(text) {
    /* process variables */
    var rExp1 = new RegExp("%([A-Z0-9]*)\\{\\\"?([^\}\\n\"]*)\\\"?\\}%", "gi");
    var rExp2 = new RegExp("%([^%]*)%", "gi");
    for (var i = 0; i < text.length; i++) {
      text[i] = text[i].replace(rExp1, '<span class="' + this.variableClass.toLowerCase() + '">$1\{$2\}</span>');
      while (text[i].search( rExp2 ) != -1) {
        text[i] = text[i].replace(rExp2, '<span class="' + this.variableClass.toLowerCase() + '">$1</span>');
      };
    };
    return text;
  };
  
  this.titlesProcess = function(text) {
    /* process titles */
    for (var i = 0; i < text.length; ++i) {
      text[i] = text[i].replace(/^---\+\+\+\+\+\+(.*)/g, "<h6>$1</h6>");
      text[i] = text[i].replace(/^---\+\+\+\+\+(.*)/g, "<h5>$1</h5>");
      text[i] = text[i].replace(/^---\+\+\+\+(.*)/g, "<h4>$1</h4>");
      text[i] = text[i].replace(/^---\+\+\+(.*)/g, "<h3>$1</h3>");
      text[i] = text[i].replace(/^---\+\+(.*)/g, "<h2>$1</h2>");
      text[i] = text[i].replace(/^---\+(.*)/g, "<h1>$1</h1>");
    };
    return text;
  };
  
  this.stylesProcess = function(text) {
    /* process styles (italic, bold, bold+italic) */
    for (var i = 0; i < text.length; ++i) {
      text[i] = text[i].replace(/(^|>|[\s(])\*([^\n*]*)\*($|<|[\s,.;:!?)])/g, "$1<b>$2</b>$3");
      text[i] = text[i].replace(/(^|>|[\s(])__([^_\n]*)__($|<|[\s,.;:!?)])/g, "$1<b><i>$2</i></b>$3");
      text[i] = text[i].replace(/(^|>|[\s(])_([^_\n]*)_($|<|[\s,.;:!?)])/g, "$1<i>$2</i>$3");
    };
    return text;
  };
  
  this.nopsProcess = function(text) {
    /* process nops */
    for (var i = 0; i < text.length; ++i) {
      text[i] = text[i].replace(/<nop[\/ ]?>/g, "");
    };
    return text;
  };
  
  /*this.verbatimsProcess = function(text) {
    text = this.replaceProcess(text, "<verbatim>", "<pre>");
    text = this.replaceProcess(text, "</verbatim>", "</pre>");
    return text;
  };*/
  
  this.separatorsProcess = function(text) {
    /* process separators */
    return this.replaceProcess(text, "-{3,}", "<hr/>");
  }
  
  this.paragraphsProcess = function(text) {
    /* process paragraphs */
    return this.replaceProcess(text, "^[ \t\x0D]*$", "<p/>");
  };
  
  this.replaceProcess = function(text, twikiTag, htmlTag) {
    /* replace tag */
    var rExp = new RegExp(twikiTag, "gi");
    for (var i = 0; i < text.length; ++i) {
      text[i] = text[i].replace(rExp, htmlTag);
    };
    return text;
  };
  
  this.orderListsProcess = function(text) {
    /* process ordered lists */
    return this.listProcess(text, "^((   )+([0-9] ){1})", "<ol>", "</ol>");
  }
  
  this.listsProcess = function(text) {
    /* process lists */
    return this.listProcess(text, "^((   )+(\\* ){1})", "<ul>", "</ul>");
  }
  
  this.listProcess = function(text, regex, openningHtmlTag, closingHtmlTag) {
    /* process list */
    var isListe = false;
    var niveau = 0;
    var p = new RegExp(regex);
    for (var i = 0; i < text.length; ++i) {
      var sCurrentLineProcess = "";
      var sCurrentLine = text[i];
      var startRegex = sCurrentLine.search(p);
      if (startRegex != -1) {
        var endRegex = startRegex + sCurrentLine.match(p)[0].length;
        if (!isListe) {
          niveau = (endRegex - 2) / 3; //Nb de ' ' moins l'astérix.
          for (var j = 0; j < niveau; ++j) {
            sCurrentLineProcess += openningHtmlTag + "\n";
          };
          isListe = true;
        };

        var iNiveau = (endRegex - 2) / 3;

        if (niveau < iNiveau) {
          iNiveau -= niveau;
          for (var j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += openningHtmlTag + "\n";
          };
          niveau += iNiveau;
        }
        else if (niveau > iNiveau) {
          iNiveau = niveau - iNiveau;
          for (var j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += closingHtmlTag + "\n";
          };
          niveau -= iNiveau;
        };
        sCurrentLineProcess += sCurrentLine.replace(new RegExp(regex, "g"), "<li>") + "</li>";
      }
      else {
        if (isListe) {
          var sOldLine = text[i - 1];
          for (var j = 0; j < niveau; ++j) {
            sOldLine += closingHtmlTag;
          };
          text[i - 1] = sOldLine;
          sCurrentLineProcess = sCurrentLine;
          isListe = false;
        }
        else {
          sCurrentLineProcess = sCurrentLine;
        };
      }
      if ( (i == text.length - 1) && isListe) {
        if (sCurrentLineProcess == "")
          sCurrentLineProcess = sCurrentLine;

        for (var j = 0; j < niveau; ++j) {
          sCurrentLineProcess += closingHtmlTag + "\n";
        };
      };
      text[i] = sCurrentLineProcess;
    };
    return text;
  };
  
  this.linksProcess = function(text) {
    /* process links */
    for (var i = 0; i < text.length; ++i) {
      text[i] = text[i].replace(/( |^)\#([^ <]*)( |$|<)/g, "$1<a name='$2'></a>");
      text[i] = text[i].replace(/(\s|>|^)\s*([A-Z]+[a-z]+\.)?([A-Z]+[a-z]+[A-Z][^ ,;$.?!<]*)/g, "$1<a href=\"$2$3\" class=\"" + this.internalLinkClass.toLowerCase() + "\">$2$3</a>");
      text[i] = text[i].replace(/\[\[([A-Z][A-Za-z]+\.)?([A-Z][a-z0-9]+[A-Z][a-zA-Z0-9]+)\]\[([^\]]*)\]\]/g, "<a href=\"$1$2\" class=\"" + this.internalLinkClass.toLowerCase() + "\">$3</a>");
      text[i] = text[i].replace(/\[\[([^\]]*)\]\[([^\]]*)\]\]/g, "<a href=\"$1\">$2</a>");
      text[i] = text[i].replace(/\[\[([A-Z][A-Za-z]+\.)?([A-Z][a-z0-9]+[A-Z][a-zA-Z0-9]+)\]\]/g, "<a href=\"$1$2\" class=\"" + this.internalLinkClass.toLowerCase() + "\">$1$2</a>");
      text[i] = text[i].replace(/\[\[([^\]]*)\]\]/g, "<a href=\"$1\">$1</a>");
    };
    return text;
  };
  
  this.tablesProcess = function(text) {
    /* process tables */
    var isTable = false;
    var listTable = new Array();
    var noStartTableLine = 0;
    for (var i = 0; i < text.length; ++i) {
      var sCurrentLine = text[i];
      if (sCurrentLine.search(/^\s*(\|[^|]+\|)+/) != -1) {
        if (!isTable) {
          isTable = true;
          listTable = new Array();
          noStartTableLine = i;
        };
        var pTd = new RegExp("([^|]+)\\|+");
        var startTdRegex = sCurrentLine.search(pTd);
        var listTr = new Array();
        while (startTdRegex != -1) {
          var sTd = sCurrentLine.match(pTd)[0];
          sCurrentLine = sCurrentLine.substring(sTd.length);
          startTdRegex = sCurrentLine.search(pTd);
          listTr.push(sTd.replace(pTd, "<td>$1</td>"));
        };
        listTable.push(listTr);
      }
      else {
        // cas ou il y a encore du texte après le tableau.
        if (isTable) {
          this.tableProcess(text, listTable, noStartTableLine);
          isTable = false;
        }
        text[i] = sCurrentLine;
      };
    };
    // cas ou le tableau est en fin de fichier.
    if (isTable) {
      this.tableProcess(text, listTable, noStartTableLine);
    };
    return text;
  };
  
  this.tableProcess = function(text, tableData, noStartTableLine) {
    /* process table */
    var sTable = "";
    for (var j = 0; j < tableData.length; j++) {
      sTable = "<tr>" + tableData[j].join("") + "</tr>\n";
      if (j == 0) {
        sTable = "<table border='1' cellspacing='0' cellpadding='0'>" + "\n" + sTable;
      }
      else if (j == tableData.length - 1) {
        sTable += "</table>" + "\n";
      };
      text[noStartTableLine + j] = sTable;
    };
  };
  
};

TwikiToHtmlTranslatorTool.prototype = new KupuTool;
