/*****************************************************************************
 * 
 * TWiki KupuEditorAddOn add-on for TWiki
 * Copyright (C) 2004 Damien Mandrioli and Romain Raugi
 * 
 * Based on original Kupu implementation.  
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 * 
 * Based on XHTML/TWikiML Translator 1.06
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

function HtmlToTwikiTranslatorTool(serverSideScript) {
  /* TWiki KupuEditorAddOn HTML to TWikiML translation */
  this.serverSideScript = serverSideScript;
  this.viewPermissionsMetaName = 'view_permissions';
  this.changePermissionsMetaName = 'change_permissions';
  this.internalLinkClass = 'INTERNAL_LINK';
  this.variableClass = 'VARIABLE';
  
  this.callServerTranslator = function(xhtml) {
    /* call server-side translator script */
    var request = Sarissa.getXmlHttpRequest();
    request.open("PUT", this.serverSideScript, false);
    request.setRequestHeader("Content-type", "application/xhtml+xml;");
    request.send(xhtml);
    if (request.status == 200)
      return request.responseText;
    else {
      alert("Unable to call server-side translator");
      return xhtml;
    }
  };
  
  this.processTabs = function(text) {
    /* process tabulations */
    // TODO : find a better regexp to replace "\t" by "   " before bullets
    return text.replace(new RegExp("\t", "g"), "   ");
  };
  
  this.translate = function(node) {
    /* translation main procedure */
    // process filtering (for Kupu specific syntax)
    var text = this.filter(node.getElementsByTagName('body')[0]);
    // translation
    text = this.callServerTranslator(text);
    text = this.processTabs(text);
    // WikiWords
    text = text.replace(/\[\[([^\]]+)\]\[\1\]\]/gi, "$1");
    // permissions
    var metaTags = node.getElementsByTagName("meta");
    var viewPerms = metaTags.namedItem(this.viewPermissionsMetaName);
    var changePerms = metaTags.namedItem(this.changePermissionsMetaName);
    if (viewPerms && viewPerms.attributes.getNamedItem("content").nodeValue != "") 
      text += "\n   * SETALLOWTOPICVIEW = " + viewPerms.attributes.getNamedItem("content").nodeValue;
    if (changePerms && changePerms.attributes.getNamedItem("content").nodeValue != "") 
      text += "\n   * SETALLOWTOPICCHANGE = " + changePerms.attributes.getNamedItem("content").nodeValue;
    return text;
  };
  
  this.filter = function(node) {
    /* process main translation */
    var sText = "";
    if (node == null) return "";
    var type = node.nodeType;
    switch (type) {
      case 1:
        // element node
        sText = this.nodeProcess(node);
        break;
      case 3:
        // text node
        var sText = node.nodeValue.replace(/([ ]+|[ \t\n\f\r])/g, ' ');
        break;
    };
    return sText;
  };
    
  this.nodeProcess = function(node) {
    /* process node element */
    var sNode = node.nodeName;
    if (sNode.toUpperCase() == "SPAN" && 
        node.className.toUpperCase() == this.variableClass) {
      return this.variablesProcess(node);
    }
    else {
      return this.htmlTagProcess(node);
    };
  };
    
  this.htmlTagProcess = function(node) {
    /* unknown html tags */
    var sNode = "";
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
      sNode += ">";
      sNode += this.getChildrenProcess(node);
      // closing tag.
      sNode += "</" + sNameNode.toLowerCase() + ">";
    }
    else {
      sNode += this.getChildrenProcess(node);
    };
    return sNode;
  };
  
  this.getChildrenProcess = function(node) {
    /* process children of a node */
    var sNode = "";
    var children = node.childNodes;
    if (children != null) {
      var len = children.length;
      for (var i = 0; i < len; i++) {
        sNode += this.filter(children.item(i));
      };
    };
    return sNode;
  };
  
  this.variablesProcess = function(node, activeSpace, newLine) {
    /* process variables */
    return "%" + this.getChildrenProcess(node) + "%";
  };
  
};

HtmlToTwikiTranslatorTool.prototype = new KupuTool;

function TwikiToHtmlTranslatorTool(serverSideScript) {
  /* TWiki KupuEditorAddOn TWikiML to HTML translation */
  this.serverSideScript = serverSideScript;

  this.callServerTranslator = function(twikitext) {
    /* call server-side translator script */
    var request = Sarissa.getXmlHttpRequest();
    request.open("PUT", this.serverSideScript, false);
    request.setRequestHeader("Content-type", "application/xhtml+xml;");
    request.send(twikitext);
    if (request.status == 200)
      return request.responseText;
    else {
      alert("Unable to call server-side translator");
      return twikitext;
    }
  };
  
  this.processTabs = function(text) {
    /* restaure tabulations */
    // TODO : find a better regexp to replace " {3}" by \t before bullets
    return text.replace(new RegExp("   ", "g"), "\t");
  };

  this.build = function(text, node) {
    /* build html document */
    // TODO : find a correct way to rebuild Kupu's DOM document
    // ...
  };
  
  this.translate = function(text, root) {
    /* translation main procedure */
    text = this.processTabs(text);
    var html = this.callServerTranslator(text);
    this.build(html, root);
  };
  
};

TwikiToHtmlTranslatorTool.prototype = new KupuTool;
