/*****************************************************************************
 * 
 * TWiki KupuEditorAddOn add-on for TWiki
 * Copyright (C) 2004 Damien Mandrioli and Romain Raugi
 * 
 * Based on original Kupu tools implementation.
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
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

function TWikiRollingTool(titles) {
  /* TWiki KupuEditorAddOn "rollover" tool for panels */
  this.objects = new Array(titles.length);
  var i = 0;
  for(i = 0; i < titles.length; i++) {
    this.objects[i] = document.getElementById(titles[i]);
  };
  
  this.initialize = function(editor) {
    /* add click event listener on registered headlines */
    this.editor = editor;
    for(i = 0; i < this.objects.length; i++) {
      addEventHandler(this.objects[i], "click", this.toggle, this);
    };
  };

  this.toggle = function( evt ) {
    /* rolling/unrolling action */
    var target = _SARISSA_IS_MOZ ? evt.target : evt.srcElement;
    var block = target.parentNode.getElementsByTagName("div")[0];
    if (block.style.display == 'none') {
      block.style.display = 'block';
    } else {
      block.style.display = 'none';
    };
  };
  
};

TWikiRollingTool.prototype = new KupuTool;

function TWikiPermsTool(blocid, headerid, viewid, changeid, inputid, listid, rmbuttonid, closeid){
  /* TWiki KupuEditorAddOn Permissions tool */
  this.pmwindow = document.getElementById(blocid);
  this.header = document.getElementById(headerid);
  this.textzone = document.getElementById(inputid);
  this.viewcheck = document.getElementById(viewid);
  this.changecheck = document.getElementById(changeid);
  this.selectelem = document.getElementById(listid);
  this.removebutton = document.getElementById(rmbuttonid);
  this.closebutton = document.getElementById(closeid);
  this.type = 'view';

  this.initialize = function(editor) {
    /* initialize events handlers */
    this.editor = editor;
    this.doc = this.editor.getInnerDocument();
    addEventHandler(this.textzone, "keydown", this.addUser, this);
    addEventHandler(this.viewcheck, "click", this.switchToView, this);
    addEventHandler(this.changecheck, "click", this.switchToChange, this);
    addEventHandler(this.removebutton, "click", this.removeUser, this);
    addEventHandler(this.closebutton, "click", this.hide, this);
    /*              
    var lis = this.doc.getElementsByTagName("meta");
      
    for (i = 0; i<lis.length; i++){
      if (lis.item(i).getAttribute("name") == "view_permissions")
        this.meta_view = lis.item(i);  
      if (lis.item(i).getAttribute("name") == "change_permissions")
        this.meta_change = lis.item(i);
    };
    */
  };
  
  this.updateState = function(selNode) {
    /* hide permissions box */
    this.hide();
  };
  
  this.show = function(command) {
    /* show permissions box */
    this.pmwindow.style.display = "block";
  };

  this.hide = function() {
    /* hide permissions box */
    this.pmwindow.style.display = "none";
  };
     
  this.removeUser = function() {
    /* remove user from list */   
    for (i = 0; i < this.selectelem.options.length; i++)
      if (this.selectelem.options[i].selected)
        this.selectelem.removeChild(this.selectelem.options[i]);
    this.synchronizeDoc();
  };
   
  this.switchToView = function() {
    /* display view permissions box */ 
    this.type = 'view';
    this.setPermsList("view_permissions");
    this.header.innerHTML = "View Permissions";
    this.show(this.type);
  };
  
  this.switchToChange = function() {
    /* display change permissions box */  
    this.type = 'change';
    this.setPermsList("change_permissions");
    this.header.innerHTML = "Change Permissions";
    this.show(this.type);
  };
  
  this.setPermsList = function(which){
    /* get permissions from meta informations */  
    var tex;
    if (which == "view_permissions")
      // tex = this.meta_view.getAttribute("content");
      tex = this.doc.getElementsByTagName("meta").namedItem('view_permissions').getAttribute("content");
    if (which == "change_permissions")
      // tex = this.meta_change.getAttribute("content");
      tex = this.doc.getElementsByTagName("meta").namedItem('change_permissions').getAttribute("content");
    while (this.selectelem.firstChild != null)
      this.selectelem.removeChild(this.selectelem.firstChild);
    var accu = new Array(); 
    var lastindex = 0;
    var j = 0;   
    for (i = 0; i < tex.length; i++){
      if (tex.charAt(i) == ',' || i == tex.length - 1){
        if (i == tex.length - 1) i++;
        var newelem = document.createElement("option");
        newelem.setAttribute("value", tex.substring(lastindex, i));
        var texelem = document.createTextNode(tex.substring(lastindex, i));
        newelem.appendChild(texelem);
        this.selectelem.appendChild(newelem);
        lastindex = i+1;
      };
    };
  };   
  
  this.synchronizeDoc = function() {
    /* synchronization with meta informations */
    var tex = "";
    if (this.selectelem.length > 0) tex = this.selectelem.item(0).value;
    for (i = 1; i < this.selectelem.length; i++){
      tex = tex + ',' + this.selectelem.item(i).value;
    };
    if (this.type == 'view')
      // this.meta_view.content = tex;
      this.doc.getElementsByTagName("meta").namedItem('view_permissions').content = tex;
    if (this.type == 'change')
      // this.meta_change.content = tex;
      this.doc.getElementsByTagName("meta").namedItem('change_permissions').content = tex;
  };
  
  this.addUser = function(evt){
    /* add user to list */
    var keyCode;
    if (document.all) keyCode = window.event.keyCode;
    else keyCode = evt.keyCode; 
    if (keyCode != 13) return;
           
    var wikiname = this.textzone.value;
      
    var newelem = document.createElement("option");
    newelem.setAttribute("value", wikiname);
    var texelem = document.createTextNode(wikiname);
    newelem.appendChild(texelem);
    this.selectelem.appendChild(newelem);
    this.synchronizeDoc();
  };
  
};

TWikiPermsTool.prototype = new KupuTool;

function TWikiAttachListTool(){
  /* TWiki KupuEditorAddOn Attachments tool */
  this.initialize = function(editor) {
    this.editor = editor;
    this.editor.logMessage('Attachments tool initialized');
  };
};

function insertAttachRef(path, filename){
  /* add attachment (hyper)link : <img> or <a>, called by iframe content */
  if (filename.toLowerCase().match(".*\.jpg$") ||
      filename.toLowerCase().match(".*\.gif$") ||
      filename.toLowerCase().match(".*\.jpeg$")||
      filename.toLowerCase().match(".*\.png$")) {
              
    var elem = this.kupu.document.document.createElement("img");
    elem.setAttribute('src', path);
    try {
      if ( this.kupu.getSelection() ) {
        this.kupu.getSelection().replaceWithNode(elem);
      } else {
        this.kupu.getSelection().insertNodeAtSelection(elem);
      };
    } catch( exception ) {};
  }
  else {
    var elem = this.kupu.document.document.createElement("a");
    elem.setAttribute('href', path);
    elem.appendChild(this.kupu.document.document.createTextNode(filename));
    try {
      if ( this.kupu.getSelection() ) {
        this.kupu.getSelection().replaceWithNode(elem);
      } else {
        this.kupu.getSelection().insertNodeAtSelection(elem);
      };
    } catch(exception) {};
  };
};

TWikiAttachListTool.prototype = new KupuTool;

function TWikiAttachListToolBox(iframeid, plainclass, activeclass) {
  /* TWiki KupuEditorAddOn Attachments toolbox */
  this.iframe = document.getElementById(iframeid);
  this.plainclass = plainclass;
  this.activeclass = activeclass;
    
  this.initialize = function(tool, editor) {
    /* tool initialization */
    this.tool = tool;
    this.editor = editor;
  };
  
  this.updateState = function(selNode) {
    /* nothing */
  };
};

TWikiAttachListToolBox.prototype = new KupuToolBox;

function TWikiVarTool(){
  /* TWiki KupuEditorAddOn Variables tool */
   
  this.initialize = function(editor) {
    /* tool initialization : nothing */
    this.editor = editor;
  };
 
  this.createVar = function(name){
    /* create span classed variable */
    var doc = this.editor.getInnerDocument();
    var span = doc.createElement('span');
    span.className = "variable";
    this.editor.insertNodeAtSelection(span, 1);
    var tex = doc.createTextNode(name);
    span.appendChild(tex);
  };
    
  this.completeState = function( selNode, evt ) {
    /* cancel EOL effect when pressed in variable span */
    var keyCode = 0;
    if (evt) keyCode = evt.keyCode;
    // EOL special treatment in Mozilla-like browsers
    if (this.editor.getBrowserName() == 'Mozilla' &&
        keyCode == 13 && selNode.className == 'variable') {
      // Put EOL at the end of the span block
      var nodes = selNode.childNodes;
      var toAdd = new Array(nodes.length);
      var k = 0;
      var i = 0;
      while ( i < nodes.length ) {
        if (nodes[i].nodeType == 3 || nodes[i].className == 'variable') 
          toAdd[k++] = nodes[i];
        selNode.removeChild(nodes[i]);
      };
      var j = 0;
      while (j < k) {
        selNode.appendChild(toAdd[j++]);
      };
      var selection = this.editor.getDocument().getWindow().getSelection();
      // Create and select text after variable
      var afterNode = selNode.nextSibling;
      var newTextNode = this.editor.getInnerDocument().createTextNode("");
      selNode.parentNode.insertBefore(newTextNode, afterNode);
      selection.selectAllChildren(selNode.nextSibling);
    };
  };
};

TWikiVarTool.prototype = new KupuTool;

function TWikiVarToolBox(myselect, mybutton, topicbutton, plainclass, activeclass){
  /* TWiki KupuEditorAddOn Variables toolbox */
  this.varSelect = document.getElementById(myselect);
  this.varButton = document.getElementById(mybutton);
  
  this.initialize = function(tool, editor) {
    /* attach the event handlers */
    this.tool = tool;
    this.editor = editor;
    this.plainclass = plainclass;
    this.activeclass = activeclass;
    addEventHandler(this.varButton, "click", this.createVar, this);          
  };

  this.createVar = function(){
    /* Call the tool to create a variable */
    this.tool.createVar(this.varSelect.options[this.varSelect.selectedIndex].value);
  };
  
};
  
TWikiVarToolBox.prototype = new KupuToolBox;

function TWikiImagesTool(buttonid, windowid){
  /* TWiki KupuEditorAddOn Images tool */
  this.imgbutton = document.getElementById(buttonid);
  this.imwindow = document.getElementById(windowid);
  
  this.initialize = function(editor) {
    /* attach events handlers and hide images' panel */
    this.editor = editor;
    //this.modifyWindow(this.imwindow);
    addEventHandler(this.imgbutton, "click", this.openImageChooser, this);
    addEventHandler(this.imwindow, "click", this.chooseImage, this);
    this.hide();
    this.editor.logMessage('TWiki Images tool initialized');
  };

  this.updateState = function(selNode) {
    /* update state of the chooser */
    this.hide();
  };

  this.openImageChooser = function() {
    /* event handler for opening the chooser */
    // display panel
    this.show();
  };
    
  this.chooseImage = function(evt) {
    /* insert chosen image (delegate to createImage) */
    // event handler for choosing the color
    var target = _SARISSA_IS_MOZ ? evt.target : evt.srcElement;
    //var cell = this.editor.getNearestParentOfType(target, 'td');
    //this.editor.execCommand(this.command, cell.getAttribute('bgColor'));
    this.createImage(target.getAttribute('src'));
    this.hide();
    this.editor.logMessage('TWiki Image chosen');
  };

  this.show = function() {
    /* show the chooser */
    this.imwindow.style.display = "block";
  };

  this.hide = function() {
    /* hide the chooser */
    this.imwindow.style.display = "none";
  };

  /*
  this.modifyWindow = function(div) {
    var lis = div.getElementsByTagName("img");
    for (i = 0; i < lis.length; i++){
      var tw = lis.item(i).width;
      var th = lis.item(i).height;
      var l = 25;
      if (th > l) {
        if (tw < th){
          lis.item(i).height = l;
          lis.item(i).width = l * (tw / th);
        }
      }
    }
    return div;
  };
  */
    
  this.createImage = function(url) {
    /* insert image in document */
    var doc = this.editor.getInnerDocument();
    if ( url ) {
      var img = doc.createElement('img');
      img.setAttribute('src', url);
      try {
        img = this.editor.insertNodeAtSelection(img);
      } catch( exception ) { this.imwindow.style.display = "none"; };
    };
  };
  
};

TWikiImagesTool.prototype = new KupuTool;

function TWikiLinkTool(cur_web) {
  /* TWiki KupuEditorAddOn Links tool */
  
  this.initialize = function(editor) {
    /* tool initialization */
    this.editor = editor;
    this.current_web = cur_web;
    this.editor.logMessage('Link tool initialized');
  };

  // the order of the arguments is a bit odd here because of backward compatibility
  this.createLink = function(url, type, name, target, isTWiki) {
    var currnode = this.editor.getSelectedNode();
        
    var no_selection;
    // test selection (insert or replace ?)
    if (this.editor.getBrowserName() == 'IE') {
      no_selection = ( this.editor.getInnerDocument().selection.type == "None" );
    } else {
      no_selection = ( this.editor.getSelection() == "" );
    };
    // put focus on editor
    if (this.editor.getBrowserName() == "IE") {
      this.editor._restoreSelection();
    } else {
      this.editor.getDocument().getWindow().focus();
    };
    // test if we are in <a> node
    var linkel = this.editor.getNearestParentOfType(currnode, 'A');
    if (!linkel) {
      // no selection : insert
      if (no_selection) {
        var doc = this.editor.getInnerDocument();
        // insert link
        var link = doc.createElement('A');
        // target
        link.setAttribute('href', url);
        // internal or external link
        if (isTWiki) 
          link.className = 'internal_link';
        // insert link node
        this.editor.insertNodeAtSelection(link, 1);
        var text = doc.createTextNode(url);
        link.appendChild(text);
      } else {
        this.editor.execCommand("CreateLink", url);
        var currnode = this.editor.getSelectedNode();
        if (this.editor.getBrowserName() == 'IE') {
          linkel = this.editor.getNearestParentOfType(currnode, 'A');
        } else {
          linkel = currnode.nextSibling;
        };
        if ( isTWiki ) {
          linkel.className = 'internal_link';
        };
      };
    } else if (type && type == 'anchor') {
      linkel.removeAttribute('href');
      linkel.setAttribute('name', name);
    };
    this.editor.logMessage('Link added');
    this.editor.updateState();
  }; 
    
  this.deleteLink = function() {
    /* delete the current link */
    var currnode = this.editor.getSelectedNode();
    var linkel = this.editor.getNearestParentOfType(currnode, 'a');
    if (!linkel) {
      this.editor.logMessage('Not inside link');
      return;
    };
    while (linkel.childNodes.length) {
      linkel.parentNode.insertBefore(linkel.childNodes[0], linkel);
    };
    linkel.parentNode.removeChild(linkel);
    this.editor.logMessage('Link removed');
    this.editor.updateState();
  };
};

TWikiLinkTool.prototype = new KupuTool;

function TWikiLinkToolBox(divOptions, optionsHeader, divTarget, targetHeader, 
                          divCurrent, divAll, divExternal, linkCurrent, linkAll, 
                          linkExternal, currentweb, allweb, inputid, buttonid, 
                          toolboxid, divbutton, catchOption, completionOption, 
                          plainclass, activeclass) {
  /* TWiki KupuEditorAddOn Links toolbox */
  this.divOptions = document.getElementById(divOptions);
  this.optionsHeader = document.getElementById(optionsHeader);
  this.divTarget = document.getElementById(divTarget);
  this.targetHeader = document.getElementById(targetHeader);
  this.divCurrent = document.getElementById(divCurrent);
  this.divAll = document.getElementById(divAll);
  this.divExternal = document.getElementById(divExternal);
  this.divButton = document.getElementById(divbutton);
  this.currentMode = document.getElementById(linkCurrent);
  this.allMode = document.getElementById(linkAll);
  this.externalMode = document.getElementById(linkExternal);
  this.currentweb = document.getElementById(currentweb);
  this.allweb = document.getElementById(allweb);
  
  this.catchOption = document.getElementById(catchOption);
  this.completionOption = document.getElementById(completionOption);
  this.doCatch = true;
  this.doComplete = true;
    
  this.input = document.getElementById(inputid);
  this.button = document.getElementById(buttonid);
  this.toolboxel = document.getElementById(toolboxid);
    
  this.plainclass = plainclass;
  this.activeclass = activeclass;
    
  this.initialize = function(tool, editor) {
    /* attach the event handlers */
    this.tool = tool;
    this.editor = editor;
        
    this.divAll.style.display = 'none';
    this.divExternal.style.display = 'none';
    this.currentMode.checked = true;
    
    addEventHandler(this.optionsHeader, "click", this.switchOptions, this);
    addEventHandler(this.targetHeader, "click", this.switchTarget, this);
    addEventHandler(this.catchOption, "change", this.setCatchOption, this);
    addEventHandler(this.completionOption, "change", this.setCompletionOption, this);
    addEventHandler(this.input, "blur", this.updateLink, this);
    addEventHandler(this.button, "click", this.addLink, this);
    addEventHandler(this.currentMode, "click", this.switchCurrentMode, this);
    addEventHandler(this.allMode, "click", this.switchAllMode, this);
    addEventHandler(this.externalMode, "click", this.switchExternalMode, this);
    addEventHandler(this.currentweb, "change", this.updateInternalLink, this);
    addEventHandler(this.allweb, "change", this.updateInternalLink, this);
  };
    
  this.switchOptions = function() {
    /* options panel rollover */
    if (this.divOptions.style.display == "none")
      this.divOptions.style.display = "block"
    else
      this.divOptions.style.display = "none";
  };
    
  this.switchTarget = function() {
    /* target panel rollover */
    if (this.divTarget.style.display == "none")
      this.divTarget.style.display = "block"
    else
      this.divTarget.style.display = "none";
  };
    
  this.setCatchOption = function() {
    /* update WikiWords catch option */
    this.doCatch = this.catchOption.checked;
  };
    
  this.setCompletionOption = function() {
    /* update WikiWords completion option */
    this.doComplete = this.completionOption.checked;
  };
    
  this.updateInternalLink = function(){
    /* update selected link */
    if (this.divButton.style.display == 'none'){
      var currnode = this.editor.getSelectedNode();
      var linkel = this.editor.getNearestParentOfType(currnode, 'A');
      if (!linkel) {
        return;
      };
        
      if (this.currentMode.checked){
        linkel.setAttribute('href', this.currentweb.value);
        linkel.childNodes[0].data = this.currentweb.value;
      };
      if (this.allMode.checked){
        linkel.setAttribute('href', this.allweb.value);
        linkel.childNodes[0].data = this.allweb.value;
      };
      if (this.editor.getBrowserName() == 'IE') 
        classtype = linkel.getAttribute('classname');
      else classtype = linkel.getAttribute('class');
      if (classtype != 'internal_link')
        linkel.className = 'internal_link';
    };
  };
  
  this.switchCurrentMode = function(){
    /* switch to current web */
    this.divCurrent.style.display = 'block';
    this.divAll.style.display = 'none';
    this.divExternal.style.display = 'none';
    this.currentweb.selectedIndex = -1;
    var linkel = this.editor.getNearestParentOfType(this.editor.getSelectedNode(), 'a');
    if (! linkel) return;
    this.divButton.style.display = 'none';
  };
  
  this.switchAllMode = function(){
    /* switch to all webs */
    this.divCurrent.style.display = 'none';
    this.divAll.style.display = 'block';
    this.divExternal.style.display = 'none';
    this.allweb.selectedIndex = -1;
    var linkel = this.editor.getNearestParentOfType(this.editor.getSelectedNode(), 'a');
    if (! linkel) return;
      this.divButton.style.display = 'none';
  };
  
  this.switchExternalMode = function(){
    /* switch to URLs links */
    this.divCurrent.style.display = 'none';
    this.divAll.style.display = 'none';
    this.divExternal.style.display = 'block';
    this.divButton.style.display = 'block';
    var linkel = this.editor.getNearestParentOfType(this.editor.getSelectedNode(), 'a');
    if (! linkel) return;
    if (this.editor.getBrowserName() == 'IE') 
      classtype = linkel.getAttribute('classname');
    else classtype = linkel.getAttribute('class');
    if (classtype == 'internal_link') 
      this.input.value = "";
  };
    
  this.updateState = function(selNode, evt) {
    /* if we're inside a link, update the input, else empty it */
    var linkel = this.editor.getNearestParentOfType(selNode, 'a');
        
    if (linkel) {
      this.divButton.style.display = 'none';
      // check first before setting a class for backward compatibility
      if (this.toolboxel) {
        this.toolboxel.className = this.activeclass;
      };
      var fullurl = linkel.getAttribute('href');
      if (linkel.className == 'internal_link') {
        var pt = fullurl.lastIndexOf('/');
        if (pt != -1) fullurl = fullurl.slice(pt+1, fullurl.length);
        // get the web from the link
        /*
        var pt = fullurl.lastIndexOf('/');
        if (pt != -1){
          sub = fullurl.slice(0, pt);
          pt = sub.lastIndexOf('/');
          if (sub)
            sub = sub.slice(pt+1,sub.length);
        }
        else{
         if (pt = fullurl.lastIndexOf('.'))
         if (sub)
           sub = sub.slice(0,pt);
         else sub = this.tool.current_web;
        }
        // sub is the web of the link
        // Current Web Mode
        if (sub == this.tool.current_web ){
          this.currentMode.checked = true;
          this.switchCurrentMode();
          var li = fullurl.lastIndexOf('/');
          if (li != -1)
            fullurl = fullurl.slice(li+1,fullurl.length);
          li = fullurl.lastIndexOf('.');
          if (li != -1)
            fullurl = fullurl.slice(li+1,fullurl.length);
          this.currentweb.value = fullurl
        }
        // All Web Mode
        else {
          this.allMode.checked = true;  
          this.switchAllMode();
          var li = fullurl.lastIndexOf('/');
          if (li != -1)
            fullurl = fullurl.slice(li+1,fullurl.length);
          if (fullurl.lastIndexOf('.') == -1)
            this.allweb.value = sub + "." + fullurl;
          else this.allweb.value = fullurl;
        }
        */
        if (fullurl.indexOf("\.") != -1) {
          this.allMode.checked = true;  
          this.switchAllMode();
          this.allweb.value = fullurl;
        } else {
          this.currentMode.checked = true;
          this.switchCurrentMode();
          this.currentweb.value = fullurl;
        };
      } else{
        // external mode
        this.externalMode.checked = true;
        this.button.childNodes[0].data = "Update Link";
        this.divButton.style.display = 'block';
        this.switchExternalMode();
        this.input.value = fullurl;
      };
    } else if (selNode) {
      this.button.childNodes[0].data = "Make Link";
      this.divButton.style.display = 'block';
      // check first before setting a class for backward compatibility
      if (this.toolboxel) {
        this.toolboxel.className = this.plainclass;
      };
      this.input.value = '';
      var type = "click";
      if (evt) type = evt.type;
      if (type == "click" && this.doCatch) {
        // update not managed WikiWords
        this.catchWikiWord(selNode);
      };
    };
  };
    
  this.getIENodeValue = function(node, depth) {
    /* node selected different in Mozilla and IE */
    if (this.editor.getBrowserName() == "IE") {
      if (node.childNodes && node.childNodes.length > 0) {
        var str = "";
        for(var k = 0; k < node.childNodes.length; k++) {
          str += this.getIENodeValue( node.childNodes[k], depth + 1 );
        };
        return str;
      };
      if (! node.nodeValue) return "";
    };
    return node.nodeValue;
  };
    
  this.getIECaretNode = function(node) {
    /* get current text node (IE) */
    var caretIndex = this.caretIndex();
    var selNode = node;
    // return effective node
    if (node.childNodes && node.childNodes.length > 0) {
      var i = 0;
      var processing = false;
      while (i < node.childNodes.length && ! processing) {
        tmp = this.getIENodeValue(node.childNodes[i], 1);
        if (node.childNodes[i].nodeType != 3) {
          // elem node
          caretIndex -= tmp.length;
          i++;
        } else if (caretIndex - tmp.length > 0) {
          caretIndex -= tmp.length;
          i++;
        } else processing = true;
      };
      selNode = node.childNodes[i];
    };
    return selNode;
  };
    
  this.getIECaretIndex = function( node ) {
    /* return relative to text node caret position */
    var caretIndex = this.caretIndex();
    // effective node
    if (node.childNodes && node.childNodes.length > 0) {
      var i = 0;
      var processing = false;
      while (i < node.childNodes.length && ! processing) {
        tmp = this.getIENodeValue(node.childNodes[i], 1);
        if (node.childNodes[i].nodeType != 3) {
          // elem node
          caretIndex -= tmp.length;
        } else if (caretIndex - tmp.length > 0) {
          caretIndex -= tmp.length;
        } else
          processing = true;
        i++;
      };
    };
    return caretIndex;
  };
    
  this.completeState = function(selNode, evt) {
    /* completion or WikiWord catching */
    // retrieve key code
    var keyCode = 0;
    if ( evt ) keyCode = evt.keyCode;
    var nodeValue = "";
    var caretIndex = 0;
    if (this.editor.getBrowserName() == "IE") {
      nodeValue = this.getIECaretNode(selNode).nodeValue;
      caretIndex = this.getIECaretIndex(selNode) - 1;
    } else {
      nodeValue = selNode.nodeValue;
      caretIndex = this.caretIndex() - 1;
    };
    // no Enter code becauseof EOL difficulties
    var sepCodes = new Array(32, 160, 125, 93, 59, 58, 44, 41);
    if (this.doComplete && (( keyCode >= 48 && keyCode <= 57 ) || 
                            ( keyCode >= 97 && keyCode <= 122 ) || 
                            ( keyCode >= 65 && keyCode <= 90 ))) {
      // complete if alphanum char code
      this.completeWikiWord(selNode);
    } else if (this.doCatch && sepCodes.contains(nodeValue.charCodeAt(caretIndex))) {
      this.catchWikiWord(selNode);
    };
  };
        
  this.completeWikiWord = function(selNode) {
    /* WikiWord completion */
    var rExp = new RegExp("(([A-Z][a-zA-Z0-9]+\.)?[A-Z][a-zA-Z0-9]*)", "");
    // completion function
    if (this.editor.getBrowserName() == "IE") selNode = this.getIECaretNode(selNode);
    if (selNode.nodeValue) {
      // must have text
      var cIdx = this.startingWord(selNode, false);
      // search pattern in the substring beginning to current position
      var idx = selNode.nodeValue.substring(cIdx).search(rExp);
      if (idx == 0) {
        // must sentence begin with a word matching this pattern
        idx = cIdx;                                
        // retrieve written word matching to pattern
        var value = this.getWikiWord( selNode.nodeValue, idx );
        var length = value.length;
        // in which list to search ?
        var list;
        if (value.indexOf(".") == -1) {
          list = this.currentweb; 
        } else {
          list = this.allweb;
        };
        var found = false;
        var k = 0;
        var lidx = -1;
        // search pattern in list
        var rExp2 = new RegExp("^" + value);
        while (k < list.options.length && ! found) {
          if ((lidx = list.options[k].value.search(rExp2)) != -1)
            found = true;
          else k++;
        };
        if (found) {
          // we found a matching item, retrieve end part
          var str = list.options[k].value.substring(length);
          // absolute offset for selection (in IE)
          var offset = 0;
          if (this.editor.getBrowserName() == "IE") {
            offset = this.caretIndex() - (idx + length) + 1;
          };
          // update data
          selNode.nodeValue = selNode.nodeValue.substring(0, idx + length) +
                              str +
                              selNode.nodeValue.substring(idx + length);
          // select part of the text
          this.select(selNode, offset + idx + length, offset + idx + length + str.length, false, false);
        };
      };
    };
  };
    
  this.catchWikiWord = function(selNode) {
    /* verify if a wikiword has been entered an catch it if this is the case */
    var rExp = new RegExp("(([A-Z][a-zA-Z0-9]+\.)?[A-Z][a-zA-Z0-9]+[A-Z][a-zA-Z0-9]+)", "");
    if (this.editor.getBrowserName() == "IE") selNode = this.getIECaretNode(selNode);
    var container = selNode.parentNode;
    if (container.className != 'variable' && container.className != 'internal_link' 
        && container.nodeName.toUpperCase() != 'PRE' && selNode.nodeValue) {
      // get starting word beginning
      var cIdx = this.startingWord(selNode, true);
      var idx = selNode.nodeValue.substring(cIdx).search(rExp);
      if (idx > -1) {
        idx += cIdx;
        // separators
        var ascii_codes = new Array(10, 160, 13, 9, 32);
        if (idx >= 0 && (idx == 0 || (ascii_codes.contains(selNode.nodeValue.charCodeAt(idx - 1))))) {
          var value = this.getWikiWord(selNode.nodeValue, idx);
          var length = value.length;
          // select part of the text
          if (this.editor.getBrowserName() != "IE")
            this.select(selNode, idx, idx + length, true, true);
          // split text node
          var textBefore = selNode.nodeValue.substr(0, idx);
          var textAfter = selNode.nodeValue.substr(idx + length);
          var beforeNode = this.editor.getInnerDocument().createTextNode(textBefore);
          var afterNode = this.editor.getInnerDocument().createTextNode(textAfter);
          // create link node
          var linkNode = this.editor.getInnerDocument().createElement("a");
          linkNode.className = "internal_link";
          linkNode.setAttribute('href', value);
          linkNode.appendChild(this.editor.getInnerDocument().createTextNode(value));
          // insert nodes
          container.insertBefore(beforeNode, selNode);
          container.insertBefore(linkNode, selNode);
          container.insertBefore(afterNode, selNode);
          // remove old node
          container.removeChild(selNode);
          // selection
          if (afterNode != null) {
            var selection;
            if (this.editor.getBrowserName() != "IE") {
              // Mozilla code
              selection = this.editor.getDocument().getWindow().getSelection();   
              // select text after link
              selection.selectAllChildren(afterNode);                          
            };
          };
        };
      };
    };
  };
    
  this.startingWord = function(node, doBack) {
    /* get beginning of a word */
    var dotFound = 0;
    // get caret position
    var caretPos = 0;
    if (this.editor.getBrowserName() == "IE") {
      caretPos = this.getIECaretIndex(node.parentNode);
    }
    else caretPos = this.caretIndex();
    if (doBack) caretPos--;
    var data = node.nodeValue;
    // return beginning word's index
    while (caretPos > 0 && (
          (data.charCodeAt(caretPos - 1) >= 48 && data.charCodeAt(caretPos - 1) <= 57) || 
          (data.charCodeAt(caretPos - 1) >= 97 && data.charCodeAt(caretPos - 1) <= 122) || 
          (data.charCodeAt(caretPos - 1) >= 65 && data.charCodeAt(caretPos - 1) <= 90)  || 
          (data.charCodeAt(caretPos - 1) == 46 && (dotFound++ == 0 )))) { caretPos--; };
    // must not start with a dot
    if (data.charCodeAt(caretPos) == 46) caretPos++;
    return caretPos;
  };
    
  this.getWikiWord = function(data, idx) {
    /* get WikiWord from index */
    var k = idx;
    var dotFound = 0;
    while (k < data.length && ((data.charCodeAt(k) >= 48 && data.charCodeAt(k) <= 57) || 
                               (data.charCodeAt(k) >= 97 && data.charCodeAt(k) <= 122) || 
                               (data.charCodeAt(k) >= 65 && data.charCodeAt(k) <= 90)  || 
                               (data.charCodeAt(k) == 46 && (dotFound++ == 0 )))) {
      k++;
    };
    // must not finish with a dot
    if (data.charCodeAt(k - 1) == 46) k--;
    return data.substring(idx, k);
  };
    
  this.select = function(node, start_idx, end_idx, doSelect, doRemove) {
    /* select part of a text node */
    var range;
    var selection;
    if (this.editor.getBrowserName() == "IE") {
      // IE code 
      selection = this.editor.getInnerDocument().selection;
      range = selection.createRange();
      var caretPos = this.caretIndex() + 1;
      range.moveEnd('character', end_idx - caretPos);
      range.moveStart('character', start_idx - end_idx);
      range.select();
    } else {
      // Mozilla code
      selection = this.editor.getDocument().getWindow().getSelection();
      if (doSelect) selection.selectAllChildren(node);
      range = selection.getRangeAt(0);
      if (doRemove) selection.removeAllRanges(); 
      range.setEnd(node, end_idx);
      range.setStart(node, start_idx);
    };
  };
    
  this.caretIndex = function() {
    /* return caret index in text */
    var range;
    var selection;
    if (this.editor.getBrowserName() == "IE") {
      // IE code
      selection = this.editor.getInnerDocument().selection;
      range = selection.createRange();
      var parent = range.parentElement();
      var elrange = range.duplicate();
      elrange.moveToElementText( parent );
      var tempstart = range.duplicate();
      var startoffset = 0;
      while (elrange.compareEndPoints('StartToStart', tempstart) < 0) {
        startoffset++;
        tempstart.moveStart('character', -1);
      };
      return startoffset - 1;      
    } else {
      // Mozilla code
      selection = this.editor.getDocument().getWindow().getSelection();
      range = selection.getRangeAt(0);
      return range.startOffset;
    };
  };
    
  this.addLink = function(event) {
    /* add a link */
    var url = this.input.value;
       
    if (this.externalMode.checked)
      this.tool.createLink(url,null,null,null,false);
    if (this.currentMode.checked)
      this.tool.createLink(this.currentweb.value,null,null,null,true);    
    if (this.allMode.checked)
      this.tool.createLink(this.allweb.value,null,null,null,true);    
  };
    
  this.updateLink = function() {
    /* update the current link */
    var currnode = this.editor.getSelectedNode();
    var linkel = this.editor.getNearestParentOfType(currnode, 'A');
    
    if (!linkel) {
      return;
    };
    if (this.editor.getBrowserName() == 'IE') 
      classtype = linkel.getAttribute('classname');
    else classtype = linkel.getAttribute('class');
    if (classtype == 'internal_link'){
      //if (this.editor.getBrowserName() == 'IE') 
      //  linkel.setAttribute('className', '');
      linkel.className = null;
    };
    var url = this.input.value;
    linkel.setAttribute('href', url);
    this.editor.logMessage('Link modified');
  };
  
};

TWikiLinkToolBox.prototype = new KupuToolBox;
