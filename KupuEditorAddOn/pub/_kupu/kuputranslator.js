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
    };
  };
  
  this.translate = function(node) {
    /* translation main procedure */
    text = this.callServerTranslator(node.innerHTML);
    return text;
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
    };
  };

  this.build = function(text, node) {
    /* build html document */
    // TODO : find a correct way to rebuild Kupu's DOM document
    // ...
  };
  
  this.translate = function(text, root) {
    /* translation main procedure */
    var html = this.callServerTranslator(text);
    this.build(html, root);
  };
  
};

TwikiToHtmlTranslatorTool.prototype = new KupuTool;
