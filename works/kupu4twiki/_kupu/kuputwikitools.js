/*****************************************************************************
 *
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 *
 * This software is distributed under the terms of the Kupu
 * License. See LICENSE.txt for license text. For a list of Kupu
 * Contributors see CREDITS.txt.
 *
 *****************************************************************************/

// $Id: kuputwikitools.js,v 1.2 2004/09/09 14:36:59 romano Exp $


//----------------------------------------------------------------------------
//
// Toolboxes
//
//  These are addons for Kupu, simple plugins that implement a certain 
//  interface to provide functionality and control view aspects.
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Superclasses
//----------------------------------------------------------------------------

function KupuTool() {
    /* Superclass (or actually more of an interface) for tools 
    
        Tools must implement at least an initialize method and an 
        updateState method, and can implement other methods to add 
        certain extra functionality (e.g. createContextMenuElements).
    */

    this.toolboxes = {};

    // methods
    this.initialize = function(editor) {
        /* Initialize the tool.

            Obviously this can be overriden but it will do
            for the most simple cases
        */
        this.editor = editor;
    };

    this.registerToolBox = function(id, toolbox) {
        /* register a ui box 
        
            Note that this needs to be called *after* the tool has been 
            registered to the KupuEditor
        */
        this.toolboxes[id] = toolbox;
        toolbox.initialize(this, this.editor);
    };
    
    this.updateState = function(selNode, event) {
        /* Is called when user moves cursor to other element 

            Calls the updateState for all toolboxes and may want perform
            some actions itself
        */
        for (id in this.toolboxes) {
            this.toolboxes[id].updateState(selNode, event);
        };
    };

    // private methods
    addEventHandler = addEventHandler;
    
    this._selectSelectItem = function(select, item) {
        this.editor.logMessage('Deprecation warning: KupuTool._selectSelectItem');
    };
}

function KupuToolBox() {
    /* Superclass for a user-interface object that controls a tool */

    this.initialize = function(tool, editor) {
        /* store a reference to the tool and the editor */
        this.tool = tool;
        this.editor = editor;
    };

    this.updateState = function(selNode, event) {
        /* update the toolbox according to the current iframe's situation */
    };
    
    this._selectSelectItem = function(select, item) {
        this.editor.logMessage('Deprecation warning: KupuToolBox._selectSelectItem');
    };
};

//----------------------------------------------------------------------------
// Implementations
//----------------------------------------------------------------------------

function KupuButton(buttonid, commandfunc, tool) {
    /* Base prototype for kupu button tools */
    this.button = window.document.getElementById(buttonid);
    this.commandfunc = commandfunc;
    this.tool = tool;

    this.initialize = function(editor) {
        this.editor = editor;
        addEventHandler(this.button, 'click', this.execCommand, this);
    };

    this.execCommand = function() {
        /* exec this button's command */
        this.commandfunc(this, this.editor, this.tool);
    };

    this.updateState = function(selNode, event) {
        /* override this in subclasses to determine whether a button should
            look 'pressed in' or not
        */
    };
};

KupuButton.prototype = new KupuTool;

function KupuStateButton(buttonid, commandfunc, checkfunc, offclass, onclass) {
    /* A button that can have two states (e.g. pressed and
       not-pressed) based on CSS classes */
    this.button = window.document.getElementById(buttonid);
    this.commandfunc = commandfunc;
    this.checkfunc = checkfunc;
    this.offclass = offclass;
    this.onclass = onclass;
    this.pressed = false;

    this.execCommand = function() {
        /* exec this button's command */
        this.commandfunc(this, this.editor);
        if (this.editor.getBrowserName() == 'Mozilla') {
            this.button.className = (this.pressed ? this.offclass : this.onclass);
            this.pressed = !this.pressed;
        };
    };

    this.updateState = function(selNode, event) {
        /* check if we need to be clicked or unclicked, and update accordingly 
        
            if the state of the button should be changed, we set the class
        */
        var currclass = this.button.className;
        var newclass = null;
        if (this.checkfunc(selNode, this, this.editor, event)) {
            newclass = this.onclass;
            this.pressed = true;
        } else {
            newclass = this.offclass;
            this.pressed = false;
        };
        if (currclass != newclass) {
            this.button.className = newclass;
        };
    };
};

KupuStateButton.prototype = new KupuButton;

function KupuRemoveElementButton(buttonid, element_name, cssclass) {
    /* A button specialized in removing elements in the current node
       context. Typical usages include removing links, images, etc. */
    this.button = window.document.getElementById(buttonid);
    this.onclass = 'invisible';
    this.offclass = cssclass;
    this.pressed = false;

    this.commandfunc = function(button, editor) {
        editor.removeNearestParentOfType(editor.getSelectedNode(), element_name);
    };

    this.checkfunc = function(currnode, button, editor, event) {
        var element = editor.getNearestParentOfType(currnode, element_name);
        return (element ? false : true);
    };
};

KupuRemoveElementButton.prototype = new KupuStateButton;

function KupuUI(textstyleselectid) {
    /* View 
    
        This is the main view, which controls most of the toolbar buttons.
        Even though this is probably never going to be removed from the view,
        it was easier to implement this as a plain tool (plugin) as well.
    */
    
    // attributes
    this.tsselect = document.getElementById(textstyleselectid);

    this.initialize = function(editor) {
        /* initialize the ui like tools */
        this.editor = editor;
        addEventHandler(this.tsselect, 'change', this.setTextStyleHandler, this);
    };

    this.setTextStyleHandler = function(event) {
        this.setTextStyle(this.tsselect.options[this.tsselect.selectedIndex].value);
    };
    
    // event handlers
    this.basicButtonHandler = function(action) {
        /* event handler for basic actions (toolbar buttons) */
        this.editor.execCommand(action);
        this.editor.updateState();
    };

    this.saveButtonHandler = function() {
        /* handler for the save button */
        this.editor.saveDocument();
    };

    this.saveAndExitButtonHandler = function(redirect_url) {
        /* save the document and, if successful, redirect */
        this.editor.saveDocument(redirect_url);
    };

    this.cutButtonHandler = function() {
        try {
            this.editor.execCommand('Cut');
        } catch (e) {
            if (this.editor.getBrowserName() == 'Mozilla') {
                alert('Cutting from JavaScript is disabled on your Mozilla due to security settings. For more information, read http://www.mozilla.org/editor/midasdemo/securityprefs.html');
            } else {
                throw e;
            };
        };
        this.editor.updateState();
    };

    this.copyButtonHandler = function() {
        try {
            this.editor.execCommand('Copy');
        } catch (e) {
            if (this.editor.getBrowserName() == 'Mozilla') {
                alert('Copying from JavaScript is disabled on your Mozilla due to security settings. For more information, read http://www.mozilla.org/editor/midasdemo/securityprefs.html');
            } else {
                throw e;
            };
        };
        this.editor.updateState();
    };

    this.pasteButtonHandler = function() {
        try {
            this.editor.execCommand('Paste');
        } catch (e) {
            if (this.editor.getBrowserName() == 'Mozilla') {
                alert('Pasting from JavaScript is disabled on your Mozilla due to security settings. For more information, read http://www.mozilla.org/editor/midasdemo/securityprefs.html');
            } else {
                throw e;
            };
        };
        this.editor.updateState();
    };

    this.setTextStyle = function(style) {
        /* method for the text style pulldown */
        // XXX Yuck!!
        if (this.editor.getBrowserName() == "IE") {
            style = '<' + style + '>';
        };
        this.editor.execCommand('formatblock', style);
    };

    this.updateState = function(selNode) {
        /* set the text-style pulldown */
    
        // first get the nearest style
        var styles = {}; // use an object here so we can use the 'in' operator later on
        for (var i=0; i < this.tsselect.options.length; i++) {
            // XXX we should cache this
            styles[this.tsselect.options[i].value.toUpperCase()] = i;
        }
        
        var currnode = selNode;
        var index = 0;
        while (currnode) {
            if (currnode.nodeName.toUpperCase() in styles) {
                index = styles[currnode.nodeName.toUpperCase()];
                break
            }
            currnode = currnode.parentNode;
        }

        this.tsselect.selectedIndex = index;
    };
  
    this.createContextMenuElements = function(selNode, event) {
        var ret = new Array();
        ret.push(new ContextMenuElement('Cut', this.cutButtonHandler, this));
        ret.push(new ContextMenuElement('Copy', this.copyButtonHandler, this));
        ret.push(new ContextMenuElement('Paste', this.pasteButtonHandler, this));
        return ret;
    };
}

KupuUI.prototype = new KupuTool;

function ColorchooserTool(fgcolorbuttonid, hlcolorbuttonid, colorchooserid) {
    /* the colorchooser */
    
    this.fgcolorbutton = document.getElementById(fgcolorbuttonid);
    this.hlcolorbutton = document.getElementById(hlcolorbuttonid);
    this.ccwindow = document.getElementById(colorchooserid);
    this.command = null;

    this.initialize = function(editor) {
        /* attach the event handlers */
        this.editor = editor;
        
        this.createColorchooser(this.ccwindow);

        addEventHandler(this.fgcolorbutton, "click", this.openFgColorChooser, this);
        addEventHandler(this.hlcolorbutton, "click", this.openHlColorChooser, this);
        addEventHandler(this.ccwindow, "click", this.chooseColor, this);

        this.hide();

        this.editor.logMessage('Colorchooser tool initialized');
    };

    this.updateState = function(selNode) {
        /* update state of the colorchooser */
        this.hide();
    };

    this.openFgColorChooser = function() {
        /* event handler for opening the colorchooser */
        this.command = "forecolor";
        this.show();
    };

    this.openHlColorChooser = function() {
        /* event handler for closing the colorchooser */
        if (this.editor.getBrowserName() == "IE") {
            this.command = "backcolor";
        } else {
            this.command = "hilitecolor";
        }
        this.show();
    };

    this.chooseColor = function(event) {
        /* event handler for choosing the color */
        var target = _SARISSA_IS_MOZ ? event.target : event.srcElement;
        var cell = this.editor.getNearestParentOfType(target, 'td');
        this.editor.execCommand(this.command, cell.getAttribute('bgColor'));
        this.hide();
    
        this.editor.logMessage('Color chosen');
    };

    this.show = function(command) {
        /* show the colorchooser */
        this.ccwindow.style.display = "block";
    };

    this.hide = function() {
        /* hide the colorchooser */
        this.command = null;
        this.ccwindow.style.display = "none";
    };

    this.createColorchooser = function(table) {
        /* create the colorchooser table */
        
        var chunks = new Array('00', '33', '66', '99', 'CC', 'FF');
        table.setAttribute('id', 'kupu-colorchooser-table');
        table.style.borderWidth = '2px';
        table.style.borderStyle = 'solid';
        table.style.position = 'absolute';
        table.style.cursor = 'default';
        table.style.display = 'none';

        var tbody = document.createElement('tbody');

        for (var i=0; i < 6; i++) {
            var tr = document.createElement('tr');
            var r = chunks[i];
            for (var j=0; j < 6; j++) {
                var g = chunks[j];
                for (var k=0; k < 6; k++) {
                    var b = chunks[k];
                    var color = '#' + r + g + b;
                    var td = document.createElement('td');
                    td.setAttribute('bgColor', color);
                    td.style.backgroundColor = color;
                    td.style.borderWidth = '1px';
                    td.style.borderStyle = 'solid';
                    td.style.fontSize = '1px';
                    td.style.width = '10px';
                    td.style.height = '10px';
                    var text = document.createTextNode('\u00a0');
                    td.appendChild(text);
                    tr.appendChild(td);
                }
            }
            tbody.appendChild(tr);
        }
        table.appendChild(tbody);

        return table;
    };
}

ColorchooserTool.prototype = new KupuTool;

function PropertyTool(titlefieldid, descfieldid) {
    /* The property tool */

    this.titlefield = document.getElementById(titlefieldid);
    this.descfield = document.getElementById(descfieldid);

    this.initialize = function(editor) {
        /* attach the event handlers and set the initial values */
        this.editor = editor;
        addEventHandler(this.titlefield, "change", this.updateProperties, this);
        addEventHandler(this.descfield, "change", this.updateProperties, this);
        
        // set the fields
        var heads = this.editor.getInnerDocument().getElementsByTagName('head');
        if (!heads[0]) {
            this.editor.logMessage('No head in document!', 1);
        } else {
            var head = heads[0];
            var titles = head.getElementsByTagName('title');
            if (titles.length) {
                this.titlefield.value = titles[0].text;
            }
            var metas = head.getElementsByTagName('meta');
            if (metas.length) {
                for (var i=0; i < metas.length; i++) {
                    var meta = metas[i];
                    if (meta.getAttribute('name') && 
                            meta.getAttribute('name').toLowerCase() == 
                            'description') {
                        this.descfield.value = meta.getAttribute('content');
                        break;
                    }
                }
            }
        }

        this.editor.logMessage('Property tool initialized');
    };

    this.updateProperties = function() {
        /* event handler for updating the properties form */
        var doc = this.editor.getInnerDocument();
        var heads = doc.getElementsByTagName('HEAD');
        if (!heads) {
            this.editor.logMessage('No head in document!', 1);
            return;
        }

        var head = heads[0];

        // set the title
        var titles = head.getElementsByTagName('title');
        if (!titles) {
            var title = doc.createElement('title');
            var text = doc.createTextNode(this.titlefield.value);
            title.appendChild(text);
            head.appendChild(title);
        } else {
            titles[0].childNodes[0].nodeValue = this.titlefield.value;
        }

        // let's just fulfill the usecase, not think about more properties
        // set the description
        var metas = doc.getElementsByTagName('meta');
        var descset = 0;
        for (var i=0; i < metas.length; i++) {
            var meta = metas[i];
            if (meta.getAttribute('name') && 
                    meta.getAttribute('name').toLowerCase() == 'description') {
                meta.setAttribute('content', this.descfield.value);
            }
        }

        if (!descset) {
            var meta = doc.createElement('meta');
            meta.setAttribute('name', 'description');
            meta.setAttribute('content', this.descfield.value);
            
            head.appendChild(meta);
        }

        this.editor.logMessage('Properties modified');
    };
}

PropertyTool.prototype = new KupuTool;

/* TWiki Permissions Tool */
function TWikiPermsTool(blocid, headerid, viewid, changeid, inputid, listid, rmbuttonid, closeid){

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
    this.editor = editor;
    this.doc = this.editor.getInnerDocument();
    addEventHandler(this.textzone, "keydown", this.addUser, this);
    addEventHandler(this.viewcheck, "click", this.switchToView, this);
    addEventHandler(this.changecheck, "click", this.switchToChange, this);
    addEventHandler(this.removebutton, "click", this.removeUser, this);
    addEventHandler(this.closebutton, "click", this.hide, this);
                  
    var lis = this.doc.getElementsByTagName("meta");
      
    for (i = 0; i<lis.length; i++){
      if (lis.item(i).getAttribute("name") == "view_permissions")
        this.meta_view = lis.item(i);  
      if (lis.item(i).getAttribute("name") == "change_permissions")
        this.meta_change = lis.item(i);
    }    
  };
  
  /* Hide permissions box */
  this.updateState = function(selNode) {
      this.hide();
  };
  
  this.show = function(command) {
      this.pmwindow.style.display = "block";
  };

  this.hide = function() {
      this.pmwindow.style.display = "none";
  };
  
  /* Remove user from list */      
  this.removeUser = function() {
      for (i = 0; i < this.selectelem.options.length; i++)
        if (this.selectelem.options[i].selected)
          this.selectelem.removeChild(this.selectelem.options[i]);
      this.synchronizeDoc();
  }    
  
  /* Display view permissions box */  
  this.switchToView = function() {
    this.type = 'view';
    this.setPermsList("view_permissions");
    this.header.innerHTML = "View Permissions";
    this.show(this.type);
  }
  
  /* Display change permissions box */  
  this.switchToChange = function() {
    this.type = 'change';
    this.setPermsList("change_permissions");
    this.header.innerHTML = "Change Permissions";
    this.show(this.type);
  }
  
  /* Get permissions from meta informations */
  this.setPermsList = function(which){
      
      if (which == "view_permissions")
        var tex = this.meta_view.getAttribute("content");
      if (which == "change_permissions")
        var tex = this.meta_change.getAttribute("content");
      
      
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
        }
      }
  }      
  
  /* Synchronization with meta informations */
  this.synchronizeDoc = function() {
  
    var tex = "";
    if ( this.selectelem.length > 0 ) tex = this.selectelem.item(0).value;
    for (i = 1; i < this.selectelem.length; i++){
      tex = tex + ',' + this.selectelem.item(i).value;
    }
    if ( this.type == 'view' )
      this.meta_view.content = tex;
    if ( this.type == 'change' )
      this.meta_change.content = tex;
  }
  
  /* Add user to list */
  this.addUser = function(evt){
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
  }
}

TWikiPermsTool.prototype = new KupuTool;

function RollingTool(titles) {
  
  /* Retrieve registered headlines */
  this.objects = new Array(titles.length);
  var i = 0;
  for( i = 0; i < titles.length; i++ ) {
    this.objects[i] = document.getElementById(titles[i]);
  }
  
  /* Add click event listener on registered headlines */
  this.initialize = function(editor) {
    this.editor = editor;
    for( i = 0; i < this.objects.length; i++ ) {
      addEventHandler(this.objects[i], "click", this.toggle, this);
    }
  }

  /* Rolling/Unrolling action */
  this.toggle = function( evt ) {
    var target = _SARISSA_IS_MOZ ? evt.target : evt.srcElement;
    var block = target.parentNode.getElementsByTagName("div")[0];
    if ( block.style.display == 'none' ) {
      block.style.display = 'block';
    } else {
      block.style.display = 'none';
    }
  }

}

RollingTool.prototype = new KupuTool;

function LinkTool(cur_web) {
    /* Add and update hyperlinks */
    
    this.initialize = function(editor) {
        this.editor = editor;
        this.current_web = cur_web;
        this.editor.logMessage('Link tool initialized');
    };
    
    this.createLinkHandler = function(event) {
        /* create a link according to a url entered in a popup */
        var linkWindow = openPopup('kupupopups/link.html', 300, 200);
        linkWindow.linktool = this;
        linkWindow.focus();
    };

    // the order of the arguments is a bit odd here because of backward compatibility
    this.createLink = function(url, type, name, target, isTWiki) {
        var currnode = this.editor.getSelectedNode();
        
        var no_selection;
        // Test selection (insert or replace ?)
        if (this.editor.getBrowserName() == 'IE') {
          
          no_selection = ( this.editor.getInnerDocument().selection.type == "None" );
        } else {
          no_selection = ( this.editor.getSelection() == "" );
        };
        // Put focus on editor
        if (this.editor.getBrowserName() == "IE") {
            this.editor._restoreSelection();
        } else {
            this.editor.getDocument().getWindow().focus();
        };
        // Test if we are in <a> node
        var linkel = this.editor.getNearestParentOfType(currnode, 'A');
        if (!linkel) {
          // No selection : insert
          if ( no_selection ) {
            var doc = this.editor.getInnerDocument();
            // Insert link
            var link = doc.createElement('A');
            // Target
            link.setAttribute('href', url);
            // Internal or external link
            if ( isTWiki ) 
              link.className = 'internal_link';
            // Insert link node
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
            }
          }
        }
        else if (type && type == 'anchor') {
          linkel.removeAttribute('href');
          linkel.setAttribute('name', name);
        }
           
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
    
    /*this.createContextMenuElements = function(selNode, event) {
        var ret = new Array();
        var link = this.editor.getNearestParentOfType(selNode, 'a');
        if (link) {
            ret.push(new ContextMenuElement('Delete link', this.deleteLink, this));
        } else {
            ret.push(new ContextMenuElement('Create link', this.createLinkHandler, this));
        };
        return ret;
    };*/
}

LinkTool.prototype = new KupuTool;

function LinkToolBox(divCurrent, divAll, divExternal, linkCurrent, linkAll, linkExternal, currentweb, allweb, inputid, buttonid, toolboxid, divbutton, plainclass, activeclass) {
    /* create and edit links */
    this.divCurrent = document.getElementById(divCurrent);
    this.divAll = document.getElementById(divAll);
    this.divExternal = document.getElementById(divExternal);
    this.divButton = document.getElementById(divbutton);
    
    this.currentMode = document.getElementById(linkCurrent);
    this.allMode = document.getElementById(linkAll);
    this.externalMode = document.getElementById(linkExternal);
    this.currentweb = document.getElementById(currentweb);
    this.allweb = document.getElementById(allweb);
    
    
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
        
        addEventHandler(this.input, "blur", this.updateLink, this);
        addEventHandler(this.button, "click", this.addLink, this);
        addEventHandler(this.currentMode, "click", this.switchCurrentMode, this);
        addEventHandler(this.allMode, "click", this.switchAllMode, this);
        addEventHandler(this.externalMode, "click", this.switchExternalMode, this);
        addEventHandler(this.currentweb, "change", this.updateInternalLink, this);
        addEventHandler(this.allweb, "change", this.updateInternalLink, this);
          
    };

    this.updateInternalLink = function(){
      if (this.divButton.style.display == 'none'){
        var currnode = this.editor.getSelectedNode();
        var linkel = this.editor.getNearestParentOfType(currnode, 'A');
        if (!linkel) {
            return;
        }
        
        if (this.currentMode.checked){
          linkel.setAttribute('href', this.currentweb.value);
          linkel.childNodes[0].data = this.currentweb.value;
          
        }
        if (this.allMode.checked){
          linkel.setAttribute('href', this.allweb.value);
          linkel.childNodes[0].data = this.allweb.value;
        }
        if (this.editor.getBrowserName() == 'IE') 
           classtype = linkel.getAttribute('classname');
        else classtype = linkel.getAttribute('class');
        if (classtype != 'internal_link')
          linkel.className = 'internal_link';
      }
    

    }
    
    this.switchCurrentMode = function(){
        this.divCurrent.style.display = 'block';
        this.divAll.style.display = 'none';
        this.divExternal.style.display = 'none';
        this.currentweb.selectedIndex = -1;
        var linkel = this.editor.getNearestParentOfType(this.editor.getSelectedNode(), 'a');
        if (! linkel) return;
        this.divButton.style.display = 'none';
        
    };
    
    this.switchAllMode = function(){
        this.divCurrent.style.display = 'none';
        this.divAll.style.display = 'block';
        this.divExternal.style.display = 'none';
        this.allweb.selectedIndex = -1;
        var linkel = this.editor.getNearestParentOfType(this.editor.getSelectedNode(), 'a');
        if (! linkel) return;
        this.divButton.style.display = 'none';
    };
    
    this.switchExternalMode = function(){
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
    
    this.updateState = function(selNode) {
        
        /* if we're inside a link, update the input, else empty it */
        var linkel = this.editor.getNearestParentOfType(selNode, 'a');
        
        if (linkel) {
          this.divButton.style.display = 'none';
          
          // check first before setting a class for backward compatibility
            if (this.toolboxel) {
                this.toolboxel.className = this.activeclass;
            };
            var fullurl = linkel.getAttribute('href');
            var sub;
            var classtype;
            if (this.editor.getBrowserName() == 'IE') 
              classtype = linkel.getAttribute('classname');
            else classtype = linkel.getAttribute('class');
            if (classtype == 'internal_link') {
                // get the web from the link
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
             }
             else{
             // External Mode
             this.externalMode.checked = true;
             this.button.childNodes[0].data = "Update Link";
             
             this.divButton.style.display = 'block';
          
             this.switchExternalMode();
             this.input.value = fullurl;
             }
        } 
        else {
            this.button.childNodes[0].data = "Make Link";
            this.divButton.style.display = 'block';
            
            // check first before setting a class for backward compatibility
            if (this.toolboxel) {
                this.toolboxel.className = this.plainclass;
            };
            this.input.value = '';
        }
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
        }
        if (this.editor.getBrowserName() == 'IE') 
              classtype = linkel.getAttribute('classname');
            else classtype = linkel.getAttribute('class');
        if (classtype == 'internal_link'){
          //if (this.editor.getBrowserName() == 'IE') 
          //  linkel.setAttribute('className', '');
          linkel.className = null;
          
        }
        var url = this.input.value;
        
        
        linkel.setAttribute('href', url);

        this.editor.logMessage('Link modified');
    };
};

LinkToolBox.prototype = new LinkToolBox;

function AttachListTool(){

    this.initialize = function(editor) {
      this.editor = editor;
      this.editor.logMessage('Attachments tool initialized');
    };
}

/* Add attachment (hyper)link : <img> or <a> */
function insertAttachRef(path, filename){
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
        }
      } catch( exception ) {}
    }
    else{
      var elem = this.kupu.document.document.createElement("a");
      elem.setAttribute('href', path);
      elem.appendChild(this.kupu.document.document.createTextNode(filename));
      try {
        if ( this.kupu.getSelection() ) {
          this.kupu.getSelection().replaceWithNode(elem);
        } else {
          this.kupu.getSelection().insertNodeAtSelection(elem);
        }
      } catch( exception ) {}
    }
}

AttachListTool.prototype = new KupuTool;

function AttachListToolBox(iframeid, plainclass, activeclass) {
    /* create and edit links */
    this.iframe = document.getElementById(iframeid);
    this.plainclass = plainclass;
    this.activeclass = activeclass;
    
    this.initialize = function(tool, editor) {
        this.tool = tool;
        this.editor = editor;
    };
    
    this.updateState = function(selNode) {}
}

/* Pallets of images (smileys ...) */
function TWikiImagesTool(buttonid, windowid){

    this.imgbutton = document.getElementById(buttonid);
    this.imwindow = document.getElementById(windowid);
    
    this.initialize = function(editor) {
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
        this.show();
    };
    
    /* Insert chosen image (delegate to createImage) */
    this.chooseImage = function(evt) {
        /* event handler for choosing the color */
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

    /*this.modifyWindow = function(div) {
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
    };*/
    
    /* Insert image */
    this.createImage = function(url) {
      var doc = this.editor.getInnerDocument();
      if ( url ) {
        var img = doc.createElement('img');
        img.setAttribute('src', url);
        try {
          img = this.editor.insertNodeAtSelection(img);
        } catch( exception ) { this.imwindow.style.display = "none"; }
      }
    }
}

TWikiImagesTool.prototype = new KupuTool;

function TWikiVarTool(){
   this.initialize = function(editor) {
        this.editor = editor;
        addEventHandler(this.editor.getDocument().getWindow(), "keydown", this.EOL, this);
    };
 
    /* Create span classed variable */
    this.createVar = function(name){
      var doc = this.editor.getInnerDocument();
      var span = doc.createElement('span');
      span.className = "variable";
      this.editor.insertNodeAtSelection(span, 1);
      var tex = doc.createTextNode(name);
      span.appendChild(tex);
    }
    
    /* Put end_of_line after variable's span for edition comfort */
    this.EOL = function( evt ) {
      var keyCode;
      if (document.all) keyCode = window.event.keyCode;
      else keyCode = evt.keyCode;
      // EOL special treatment
      if ( keyCode == 13 ) {
        var currnode = this.editor.getSelectedNode();
        var class_id = ( this.editor.getBrowserName() == "IE" )?"className":"class";
        var classname;
        if ( currnode.nodeType == 3 ) {
          classname = currnode.parentNode.getAttribute(class_id);    
        } else {
          classname = currnode.getAttribute(class_id);
        }
        // Put EOL at the end of the span block
        if ( classname == "variable" ) {
          var offsetparent = currnode.parentNode;
          var selection = this.editor.getSelection();
          currnode.parentNode.appendChild(this.editor.getInnerDocument().createElement("br"));
          selection.selectNodeContents(currnode.parentNode.nextSibling);
        }
      }
    }
}

TWikiVarTool.prototype = new KupuTool;

function TWikiVarToolBox(myselect, mybutton, topicbutton, plainclass, activeclass){
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
    this.tool.createVar(this.varSelect.options[this.varSelect.selectedIndex].value);
  }
  
}
  
TWikiVarToolBox.prototype = new KupuToolBox;

function ImageTool() {
    /* Image tool to add images */
    
    this.initialize = function(editor) {
        /* attach the event handlers */
        this.editor = editor;
        this.editor.logMessage('Image tool initialized');
    };

    this.createImageHandler = function(event) {
        /* create an image according to a url entered in a popup */
        var imageWindow = openPopup('kupupopups/image.html', 300, 200);
        imageWindow.imagetool = this;
        imageWindow.focus();
    };
    
    this.createImage = function(url) {
        var img = this.editor.getInnerDocument().createElement('img');
        img.setAttribute('src', url);
        img = this.editor.insertNodeAtSelection(img, 1);
        this.editor.logMessage('Image inserted');
        return img;
    };
    
    /*this.createContextMenuElements = function(selNode, event) {
        return new Array(new ContextMenuElement('Create image', this.createImageHandler, this));
    };*/
}

ImageTool.prototype = new KupuTool;

function ImageToolBox(inputfieldid, insertbuttonid, toolboxid, plainclass, activeclass) {
    /* toolbox for adding images */

    this.inputfield = document.getElementById(inputfieldid);
    this.insertbutton = document.getElementById(insertbuttonid);
    this.toolboxel = document.getElementById(toolboxid);
    this.plainclass = plainclass;
    this.activeclass = activeclass;

    this.initialize = function(tool, editor) {
        this.tool = tool;
        this.editor = editor;
        addEventHandler(this.insertbutton, "click", this.addImage, this);
    };

    this.updateState = function(selNode, event) {
        /* update the state of the toolbox element */
        var imageel = this.editor.getNearestParentOfType(selNode, 'img');
        if (imageel) {
            // check first before setting a class for backward compatibility
            if (this.toolboxel) {
                this.toolboxel.className = this.activeclass;
            };
        } else {
            if (this.toolboxel) {
                this.toolboxel.className = this.plainclass;
            };
        };
    };
    
    this.addImage = function() {
        /* add an image */
        var url = this.inputfield.value;
        this.tool.createImage(url);
    };
};

ImageToolBox.prototype = new KupuToolBox;

function TableTool() {
    /* The table tool */

    // XXX There are some awfully long methods in here!!
    /*this.createContextMenuElements = function(selNode, event) {
        var table =  this.editor.getNearestParentOfType(selNode, 'table');
        if (!table) {
            ret = new Array();
            var el = new ContextMenuElement('Add table', this.addPlainTable, this);
            ret.push(el);
            return ret;
        } else {
            var ret = new Array();
            ret.push(new ContextMenuElement('Add row', this.addTableRow, this));
            ret.push(new ContextMenuElement('Delete row', this.delTableRow, this));
            ret.push(new ContextMenuElement('Add column', this.addTableColumn, this));
            ret.push(new ContextMenuElement('Delete column', this.delTableColumn, this));
            ret.push(new ContextMenuElement('Delete Table', this.delTable, this));
            return ret;
        };
    };*/

    this.addPlainTable = function() {
        /* event handler for the context menu */
        this.createTable(2, 3, 1, 'plain');
    };

    this.createTable = function(rows, cols, makeHeader, tableclass) {
        /* add a table */
        var doc = this.editor.getInnerDocument();

        table = doc.createElement("table");
        table.setAttribute("border", "1");
        table.setAttribute("cellpadding", "8");
        table.setAttribute("cellspacing", "2");
        table.setAttribute("class", tableclass);

        // If the user wants a row of headings, make them
        if (makeHeader) {
            var tr = doc.createElement("tr");
            var thead = doc.createElement("thead");
            for (i=0; i < cols; i++) {
                var th = doc.createElement("th");
                th.appendChild(doc.createTextNode("Col " + i+1));
                tr.appendChild(th);
            }
            thead.appendChild(tr);
            table.appendChild(thead);
        }

        tbody = doc.createElement("tbody");
        for (var i=0; i < rows; i++) {
            var tr = doc.createElement("tr");
            for (var j=0; j < cols; j++) {
                var td = doc.createElement("td");
                var content = doc.createTextNode('\u00a0');
                td.appendChild(content);
                tr.appendChild(td);
            }
            tbody.appendChild(tr);
        }
        table.appendChild(tbody);
        this.editor.insertNodeAtSelection(table);

        this.editor.logMessage('Table added');
    };

    this.addTableRow = function() {
        /* Find the current row and add a row after it */
        var currnode = this.editor.getSelectedNode();
        var currtbody = this.editor.getNearestParentOfType(currnode, "TBODY");
        var bodytype = "tbody";
        if (!currtbody) {
            currtbody = this.editor.getNearestParentOfType(currnode, "THEAD");
            bodytype = "thead";
        }
        var parentrow = this.editor.getNearestParentOfType(currnode, "TR");
        var nextrow = parentrow.nextSibling;

        // get the number of cells we should place
        var colcount = 0;
        for (var i=0; i < currtbody.childNodes.length; i++) {
            var el = currtbody.childNodes[i];
            if (el.nodeType != 1) {
                continue;
            }
            if (el.nodeName.toLowerCase() == 'tr') {
                var cols = 0;
                for (var j=0; j < el.childNodes.length; j++) {
                    if (el.childNodes[j].nodeType == 1) {
                        cols++;
                    }
                }
                if (cols > colcount) {
                    colcount = cols;
                }
            }
        }

        var newrow = this.editor.getInnerDocument().createElement("TR");

        for (var i = 0; i < colcount; i++) {
            var newcell;
            if (bodytype == 'tbody') {
                newcell = this.editor.getInnerDocument().createElement("TD");
            } else {
                newcell = this.editor.getInnerDocument().createElement("TH");
            }
            var newcellvalue = this.editor.getInnerDocument().createTextNode("\u00a0");
            newcell.appendChild(newcellvalue);
            newrow.appendChild(newcell);
        }

        if (!nextrow) {
            currtbody.appendChild(newrow);
        } else {
            currtbody.insertBefore(newrow, nextrow);
        }
        
        this.editor.logMessage('Table row added');
    };

    this.delTableRow = function() {
        /* Find the current row and delete it */
        var currnode = this.editor.getSelectedNode();
        var parentrow = this.editor.getNearestParentOfType(currnode, "TR");
        if (!parentrow) {
            this.editor.logMessage('No row to delete', 1);
            return;
        }

        // remove the row
        parentrow.parentNode.removeChild(parentrow);

        this.editor.logMessage('Table row removed');
    };

    this.addTableColumn = function() {
        /* Add a new column after the current column */
        var currnode = this.editor.getSelectedNode();
        var currtd = this.editor.getNearestParentOfType(currnode, 'TD');
        if (!currtd) {
            currtd = this.editor.getNearestParentOfType(currnode, 'TH');
        }
        if (!currtd) {
            this.editor.logMessage('No parentcolumn found!', 1);
            return;
        }
        var currtr = this.editor.getNearestParentOfType(currnode, 'TR');
        var currtable = this.editor.getNearestParentOfType(currnode, 'TABLE');
        
        // get the current index
        var tdindex = this._getColIndex(currtd);
        this.editor.logMessage('tdindex: ' + tdindex);

        // now add a column to all rows
        // first the thead
        var theads = currtable.getElementsByTagName('THEAD');
        if (theads) {
            for (var i=0; i < theads.length; i++) {
                // let's assume table heads only have ths
                var currthead = theads[i];
                for (var j=0; j < currthead.childNodes.length; j++) {
                    var tr = currthead.childNodes[j];
                    if (tr.nodeType != 1) {
                        continue;
                    }
                    var currindex = 0;
                    for (var k=0; k < tr.childNodes.length; k++) {
                        var th = tr.childNodes[k];
                        if (th.nodeType != 1) {
                            continue;
                        }
                        if (currindex == tdindex) {
                            var doc = this.editor.getInnerDocument();
                            var newth = doc.createElement('th');
                            var text = doc.createTextNode('\u00a0');
                            newth.appendChild(text);
                            if (tr.childNodes.length == k+1) {
                                // the column will be on the end of the row
                                tr.appendChild(newth);
                            } else {
                                tr.insertBefore(newth, tr.childNodes[k + 1]);
                            }
                            break;
                        }
                        currindex++;
                    }
                }
            }
        }

        // then the tbody
        var tbodies = currtable.getElementsByTagName('TBODY');
        if (tbodies) {
            for (var i=0; i < tbodies.length; i++) {
                // let's assume table heads only have ths
                var currtbody = tbodies[i];
                for (var j=0; j < currtbody.childNodes.length; j++) {
                    var tr = currtbody.childNodes[j];
                    if (tr.nodeType != 1) {
                        continue;
                    }
                    var currindex = 0;
                    for (var k=0; k < tr.childNodes.length; k++) {
                        var td = tr.childNodes[k];
                        if (td.nodeType != 1) {
                            continue;
                        }
                        if (currindex == tdindex) {
                            var doc = this.editor.getInnerDocument();
                            var newtd = doc.createElement('td');
                            var text = doc.createTextNode('\u00a0');
                            newtd.appendChild(text);
                            if (tr.childNodes.length == k+1) {
                                // the column will be on the end of the row
                                tr.appendChild(newtd);
                            } else {
                                tr.insertBefore(newtd, tr.childNodes[k + 1]);
                            }
                            break;
                        }
                        currindex++;
                    }
                }
            }
        }
        this.editor.logMessage('Table column added');
    };

    this.delTableColumn = function() {
        /* remove a column */
        var currnode = this.editor.getSelectedNode();
        var currtd = this.editor.getNearestParentOfType(currnode, 'TD');
        if (!currtd) {
            currtd = this.editor.getNearestParentOfType(currnode, 'TH');
        }
        var currcolindex = this._getColIndex(currtd);
        var currtable = this.editor.getNearestParentOfType(currnode, 'TABLE');

        // remove the theaders
        var heads = currtable.getElementsByTagName('THEAD');
        if (heads.length) {
            for (var i=0; i < heads.length; i++) {
                var thead = heads[i];
                for (var j=0; j < thead.childNodes.length; j++) {
                    var tr = thead.childNodes[j];
                    if (tr.nodeType != 1) {
                        continue;
                    }
                    var currindex = 0;
                    for (var k=0; k < tr.childNodes.length; k++) {
                        var th = tr.childNodes[k];
                        if (th.nodeType != 1) {
                            continue;
                        }
                        if (currindex == currcolindex) {
                            tr.removeChild(th);
                            break;
                        }
                        currindex++;
                    }
                }
            }
        }

        // now we remove the column field, a bit harder since we need to take 
        // colspan and rowspan into account XXX Not right, fix theads as well
        var bodies = currtable.getElementsByTagName('TBODY');
        for (var i=0; i < bodies.length; i++) {
            var currtbody = bodies[i];
            var relevant_rowspan = 0;
            for (var j=0; j < currtbody.childNodes.length; j++) {
                var tr = currtbody.childNodes[j];
                if (tr.nodeType != 1) {
                    continue;
                }
                var currindex = 0
                for (var k=0; k < tr.childNodes.length; k++) {
                    var cell = tr.childNodes[k];
                    if (cell.nodeType != 1) {
                        continue;
                    }
                    var colspan = cell.getAttribute('colspan');
                    if (currindex == currcolindex) {
                        tr.removeChild(cell);
                        break;
                    }
                    currindex++;
                }
            }
        }
        this.editor.logMessage('Table column deleted');
    };

    this.delTable = function() {
        /* delete the current table */
        var currnode = this.editor.getSelectedNode();
        var table = this.editor.getNearestParentOfType(currnode, 'table');
        if (!table) {
            this.editor.logMessage('Not inside a table!');
            return;
        };
        table.parentNode.removeChild(table);
        this.editor.logMessage('Table removed');
    };

    this.setColumnAlign = function(newalign) {
        /* change the alignment of a full column */
        var currnode = this.editor.getSelectedNode();
        var currtd = this.editor.getNearestParentOfType(currnode, "TD");
        var bodytype = 'tbody';
        if (!currtd) {
            currtd = this.editor.getNearestParentOfType(currnode, "TH");
            bodytype = 'thead';
        }
        var currcolindex = this._getColIndex(currtd);
        var currtable = this.editor.getNearestParentOfType(currnode, "TABLE");

        // unfortunately this is not enough to make the browsers display
        // the align, we need to set it on individual cells as well and
        // mind the rowspan...
        for (var i=0; i < currtable.childNodes.length; i++) {
            var currtbody = currtable.childNodes[i];
            if (currtbody.nodeType != 1 || 
                    (currtbody.nodeName.toUpperCase() != "THEAD" &&
                        currtbody.nodeName.toUpperCase() != "TBODY")) {
                continue;
            }
            for (var j=0; j < currtbody.childNodes.length; j++) {
                var row = currtbody.childNodes[j];
                if (row.nodeType != 1) {
                    continue;
                }
                var index = 0;
                for (var k=0; k < row.childNodes.length; k++) {
                    var cell = row.childNodes[k];
                    if (cell.nodeType != 1) {
                        continue;
                    }
                    if (index == currcolindex) {
                        if (this.editor.config.use_css) {
                            cell.style.textAlign = newalign;
                        } else {
                            cell.setAttribute('align', newalign);
                        }
                        cell.className = 'align-' + newalign;
                    }
                    index++;
                }
            }
        }
    };

    this.setTableClass = function(sel_class) {
        /* set the class for the table */
        var currnode = this.editor.getSelectedNode();
        var currtable = this.editor.getNearestParentOfType(currnode, 'TABLE');

        if (currtable) {
            currtable.className = sel_class;
        }
    };

    this._getColIndex = function(currcell) {
        /* Given a node, return an integer for which column it is */
        var prevsib = currcell.previousSibling;
        var currcolindex = 0;
        while (prevsib) {
            if (prevsib.nodeType == 1 && 
                    (prevsib.tagName.toUpperCase() == "TD" || 
                        prevsib.tagName.toUpperCase() == "TH")) {
                var colspan = prevsib.getAttribute('colspan');
                if (colspan) {
                    currcolindex += parseInt(colspan);
                } else {
                    currcolindex++;
                }
            }
            prevsib = prevsib.previousSibling;
            if (currcolindex > 30) {
                alert("Recursion detected when counting column position");
                return;
            }
        }

        return currcolindex;
    };
};

TableTool.prototype = new KupuTool;

function TableToolBox(addtabledivid, edittabledivid, newrowsinputid, 
                    newcolsinputid, makeheaderinputid, classselectid, alignselectid, addtablebuttonid,
                    addrowbuttonid, delrowbuttonid, addcolbuttonid, delcolbuttonid,
                    toolboxid, plainclass, activeclass) {
    /* The table tool */

    // XXX There are some awfully long methods in here!!
    

    // a lot of dependencies on html elements here, but most implementations
    // will use them all I guess
    this.addtablediv = document.getElementById(addtabledivid);
    this.edittablediv = document.getElementById(edittabledivid);
    this.newrowsinput = document.getElementById(newrowsinputid);
    this.newcolsinput = document.getElementById(newcolsinputid);
    this.makeheaderinput = document.getElementById(makeheaderinputid);
    this.classselect = document.getElementById(classselectid);
    this.alignselect = document.getElementById(alignselectid);
    this.addtablebutton = document.getElementById(addtablebuttonid);
    this.addrowbutton = document.getElementById(addrowbuttonid);
    this.delrowbutton = document.getElementById(delrowbuttonid);
    this.addcolbutton = document.getElementById(addcolbuttonid);
    this.delcolbutton = document.getElementById(delcolbuttonid);
    this.toolboxel = document.getElementById(toolboxid);
    this.plainclass = plainclass;
    this.activeclass = activeclass;

    // register event handlers
    this.initialize = function(tool, editor) {
        /* attach the event handlers */
        this.tool = tool;
        this.editor = editor;
        addEventHandler(this.addtablebutton, "click", this.addTable, this);
        addEventHandler(this.addrowbutton, "click", this.tool.addTableRow, this.tool);
        addEventHandler(this.delrowbutton, "click", this.tool.delTableRow, this.tool);
        addEventHandler(this.addcolbutton, "click", this.tool.addTableColumn, this.tool);
        addEventHandler(this.delcolbutton, "click", this.tool.delTableColumn, this.tool);
        addEventHandler(this.alignselect, "change", this.setColumnAlign, this);
        addEventHandler(this.classselect, "change", this.setTableClass, this);
        this.addtablediv.style.display = "block";
        this.edittablediv.style.display = "none";
        this.editor.logMessage('Table tool initialized');
    };

    this.updateState = function(selNode) {
        /* update the state (add/edit) and update the pulldowns (if required) */
        var table = this.editor.getNearestParentOfType(selNode, 'table');
        if (table) {
            this.addtablediv.style.display = "none";
            this.edittablediv.style.display = "block";
            var td = this.editor.getNearestParentOfType(selNode, 'td');
            if (!td) {
                td = this.editor.getNearestParentOfType(selNode, 'th');
            };
            if (td) {
                var align = td.getAttribute('align');
                if (this.editor.config.use_css) {
                    align = td.style.textAlign;
                };
                selectSelectItem(this.alignselect, align);
            };
            selectSelectItem(this.classselect, table.className);
            if (this.toolboxel) {
                this.toolboxel.className = this.activeclass;
            };
        } else {
            this.edittablediv.style.display = "none";
            this.addtablediv.style.display = "block";
            this.alignselect.selectedIndex = 0;
            this.classselect.selectedIndex = 0;
            if (this.toolboxel) {
                this.toolboxel.className = this.plainclass;
            };
        };
    };

    this.addTable = function() {
        /* add a table */
        var rows = this.newrowsinput.value;
        var cols = this.newcolsinput.value;
        var makeHeader = this.makeheaderinput.checked;
        var classchooser = document.getElementById("kupu-table-classchooser-add");
        var tableclass = this.classselect.options[this.classselect.selectedIndex].value;
        
        this.tool.createTable(rows, cols, makeHeader, tableclass);
    };

    this.setColumnAlign = function() {
        /* set the alignment of the current column */
        var newalign = this.alignselect.options[this.alignselect.selectedIndex].value;
        this.tool.setColumnAlign(newalign);
    };

    this.setTableClass = function() {
        /* set the class for the current table */
        var sel_class = this.classselect.options[this.classselect.selectedIndex].value;
        if (sel_class) {
            this.tool.setTableClass(sel_class);
        };
    };
};

TableToolBox.prototype = new KupuToolBox;

function ListTool(addulbuttonid, addolbuttonid, ulstyleselectid, olstyleselectid) {
    /* tool to set list styles */

    this.addulbutton = document.getElementById(addulbuttonid);
    this.addolbutton = document.getElementById(addolbuttonid);
    this.ulselect = document.getElementById(ulstyleselectid);
    this.olselect = document.getElementById(olstyleselectid);

    this.style_to_type = {'decimal': '1',
                            'lower-alpha': 'a',
                            'upper-alpha': 'A',
                            'lower-roman': 'i',
                            'upper-roman': 'I',
                            'disc': 'disc',
                            'square': 'square',
                            'circle': 'circle',
                            'none': 'none'
                            };
    this.type_to_style = {'1': 'decimal',
                            'a': 'lower-alpha',
                            'A': 'upper-alpha',
                            'i': 'lower-roman',
                            'I': 'upper-roman',
                            'disc': 'disc',
                            'square': 'square',
                            'circle': 'circle',
                            'none': 'none'
                            };
    
    this.initialize = function(editor) {
        /* attach event handlers */
        this.editor = editor;

        addEventHandler(this.addulbutton, "click", this.addUnorderedList, this);
        addEventHandler(this.addolbutton, "click", this.addOrderedList, this);
        addEventHandler(this.ulselect, "change", this.setUnorderedListStyle, this);
        addEventHandler(this.olselect, "change", this.setOrderedListStyle, this);
        this.ulselect.style.display = "none";
        this.olselect.style.display = "none";

        this.editor.logMessage('List style tool initialized');
    };

    this.updateState = function(selNode) {
        /* update the visibility and selection of the list type pulldowns */
        // we're going to walk through the tree manually since we want to 
        // check on 2 items at the same time
        /*
        var currnode = selNode;
        while (currnode) {
            if (currnode.nodeName.toLowerCase() == 'ul') {
                if (this.editor.config.use_css) {
                    var currstyle = currnode.style.listStyleType;
                } else {
                    var currstyle = this.type_to_style[currnode.getAttribute('type')];
                }
                selectSelectItem(this.ulselect, currstyle);
                this.olselect.style.display = "none";
                this.ulselect.style.display = "inline";
                return;
            } else if (currnode.nodeName.toLowerCase() == 'ol') {
                if (this.editor.config.use_css) {
                    var currstyle = currnode.listStyleType;
                } else {
                    var currstyle = this.type_to_style[currnode.getAttribute('type')];
                }
                selectSelectItem(this.olselect, currstyle);
                this.ulselect.style.display = "none";
                this.olselect.style.display = "inline";
                return;
            }

            currnode = currnode.parentNode;
            this.ulselect.selectedIndex = 0;
            this.olselect.selectedIndex = 0;
        }
        */
        this.ulselect.style.display = "none";
        this.olselect.style.display = "none";
    };

    this.addUnorderedList = function() {
        /* add an unordered list */
        this.ulselect.style.display = "inline";
        this.olselect.style.display = "none";
        this.editor.execCommand("insertunorderedlist");
    };

    this.addOrderedList = function() {
        /* add an ordered list */
        this.olselect.style.display = "inline";
        this.ulselect.style.display = "none";
        this.editor.execCommand("insertorderedlist");
    };

    this.setUnorderedListStyle = function() {
        /* set the type of an ul */
        var currnode = this.editor.getSelectedNode();
        var ul = this.editor.getNearestParentOfType(currnode, 'ul');
        var style = this.ulselect.options[this.ulselect.selectedIndex].value;
        if (this.editor.config.use_css) {
            ul.style.listStyleType = style;
        } else {
            ul.setAttribute('type', this.style_to_type[style]);
        }

        this.editor.logMessage('List style changed');
    };

    this.setOrderedListStyle = function() {
        /* set the type of an ol */
        var currnode = this.editor.getSelectedNode();
        var ol = this.editor.getNearestParentOfType(currnode, 'ol');
        var style = this.olselect.options[this.olselect.selectedIndex].value;
        if (this.editor.config.use_css) {
            ol.style.listStyleType = style;
        } else {
            ol.setAttribute('type', this.style_to_type[style]);
        }

        this.editor.logMessage('List style changed');
    };
};

ListTool.prototype = new KupuTool;

function ShowPathTool() {
    /* shows the path to the current element in the status bar */

    this.updateState = function(selNode) {
        /* calculate and display the path */
        var path = '';
        var currnode = selNode;
        while (currnode != null && currnode.nodeName != '#document') {
            path = '/' + currnode.nodeName.toLowerCase() + path;
            currnode = currnode.parentNode;
        }
        
        try {
            window.status = path;
        } catch (e) {
            this.editor.logMessage('Could not set status bar message, ' +
                                    'check your browser\'s security settings.', 
                                    1);
        };
    };
};

ShowPathTool.prototype = new KupuTool;

function ViewSourceTool() {
    /* tool to provide a 'show source' context menu option */
    this.sourceWindow = null;
    
    this.viewSource = function() {
        /* open a window and write the current contents of the iframe to it */
        if (this.sourceWindow) {
            this.sourceWindow.close();
        };
        this.sourceWindow = window.open('#', 'sourceWindow');
        
        //var transform = this.editor._filterContent(this.editor.getInnerDocument().documentElement);
        //var contents = transform.xml; 
        var contents = '<html>\n' + this.editor.getInnerDocument().documentElement.innerHTML + '\n</html>';
        
        var doc = this.sourceWindow.document;
        doc.write('\xa0');
        doc.close();
        var body = doc.getElementsByTagName("body")[0];
        while (body.hasChildNodes()) {
            body.removeChild(body.firstChild);
        };
        var pre = doc.createElement('pre');
        var textNode = doc.createTextNode(contents);
        body.appendChild(pre);
        pre.appendChild(textNode);
    };
    
    this.createContextMenuElements = function(selNode, event) {
        /* create the context menu element */
        return new Array(new ContextMenuElement('View source', this.viewSource, this));
    };
};

ViewSourceTool.prototype = new KupuTool;

function DefinitionListTool(dlbuttonid) {
    /* a tool for managing definition lists

        the dl elements should behave much like plain lists, and the keypress
        behaviour should be similar
    */

    this.dlbutton = document.getElementById(dlbuttonid);
    
    this.initialize = function(editor) {
        /* initialize the tool */
        this.editor = editor;
        addEventHandler(this.dlbutton, 'click', this.createDefinitionList, this);
        addEventHandler(editor.getInnerDocument(), 'keyup', this._keyDownHandler, this);
        addEventHandler(editor.getInnerDocument(), 'keypress', this._keyPressHandler, this);
    };

    // even though the following methods may seem view related, they belong 
    // here, since they describe core functionality rather then view-specific
    // stuff
    this.handleEnterPress = function(selNode) {
        var dl = this.editor.getNearestParentOfType(selNode, 'dl');
        if (dl) {
            var dt = this.editor.getNearestParentOfType(selNode, 'dt');
            if (dt) {
                if (dt.childNodes.length == 1 && dt.childNodes[0].nodeValue == '\xa0') {
                    this.escapeFromDefinitionList(dl, dt, selNode);
                    return;
                };

                var selection = this.editor.getSelection();
                var startoffset = selection.startOffset();
                var endoffset = selection.endOffset(); 
                if (endoffset > startoffset) {
                    // throw away any selected stuff
                    selection.cutChunk(startoffset, endoffset);
                    selection = this.editor.getSelection();
                    startoffset = selection.startOffset();
                };
                
                var ellength = selection.getElementLength(selection.parentElement());
                if (startoffset >= ellength - 1) {
                    // create a new element
                    this.createDefinition(dl, dt);
                } else {
                    var doc = this.editor.getInnerDocument();
                    var newdt = selection.splitNodeAtSelection(dt);
                    var newdd = doc.createElement('dd');
                    while (newdt.hasChildNodes()) {
                        if (newdt.firstChild != newdt.lastChild || newdt.firstChild.nodeName.toLowerCase() != 'br') {
                            newdd.appendChild(newdt.firstChild);
                        };
                    };
                    newdt.parentNode.replaceChild(newdd, newdt);
                    selection.selectNodeContents(newdd);
                    selection.collapse();
                };
            } else {
                var dd = this.editor.getNearestParentOfType(selNode, 'dd');
                if (!dd) {
                    this.editor.logMessage('Not inside a definition list element!');
                    return;
                };
                if (dd.childNodes.length == 1 && dd.childNodes[0].nodeValue == '\xa0') {
                    this.escapeFromDefinitionList(dl, dd, selNode);
                    return;
                };
                var selection = this.editor.getSelection();
                var startoffset = selection.startOffset();
                var endoffset = selection.endOffset();
                if (endoffset > startoffset) {
                    // throw away any selected stuff
                    selection.cutChunk(startoffset, endoffset);
                    selection = this.editor.getSelection();
                    startoffset = selection.startOffset();
                };
                var ellength = selection.getElementLength(selection.parentElement());
                if (startoffset >= ellength - 1) {
                    // create a new element
                    this.createDefinitionTerm(dl, dd);
                } else {
                    // add a break and continue in this element
                    var br = this.editor.getInnerDocument().createElement('br');
                    this.editor.insertNodeAtSelection(br, 1);
                    //var selection = this.editor.getSelection();
                    //selection.moveStart(1);
                    selection.collapse(true);
                };
            };
        };
    };

    this.handleTabPress = function(selNode) {
    };

    this._keyDownHandler = function(event) {
        var selNode = this.editor.getSelectedNode();
        var dl = this.editor.getNearestParentOfType(selNode, 'dl');
        if (!dl) {
            return;
        };
        switch (event.keyCode) {
            case 13:
                if (event.preventDefault) {
                    event.preventDefault();
                } else {
                    event.returnValue = false;
                };
                break;
        };
    };

    this._keyPressHandler = function(event) {
        var selNode = this.editor.getSelectedNode();
        var dl = this.editor.getNearestParentOfType(selNode, 'dl');
        if (!dl) {
            return;
        };
        switch (event.keyCode) {
            case 13:
                this.handleEnterPress(selNode);
                if (event.preventDefault) {
                    event.preventDefault();
                } else {
                    event.returnValue = false;
                };
                break;
            case 9:
                if (event.preventDefault) {
                    event.preventDefault();
                } else {
                    event.returnValue = false;
                };
                this.handleTabPress(selNode);
        };
    };

    this.createDefinitionList = function() {
        /* create a new definition list (dl) */
        var selection = this.editor.getSelection();
        var doc = this.editor.getInnerDocument();

        var selection = this.editor.getSelection();
        var cloned = selection.cloneContents();
        // first get the 'first line' (until the first break) and use it
        // as the dt's content
        var iterator = new NodeIterator(cloned);
        var currnode = null;
        var remove = false;
        while (currnode = iterator.next()) {
            if (currnode.nodeName.toLowerCase() == 'br') {
                remove = true;
            };
            if (remove) {
                var next = currnode;
                while (!next.nextSibling) {
                    next = next.parentNode;
                };
                next = next.nextSibling;
                iterator.setCurrent(next);
                currnode.parentNode.removeChild(currnode);
            };
        };

        var dtcontentcontainer = cloned;
        var collapsetoend = false;
        
        var dl = doc.createElement('dl');
        this.editor.insertNodeAtSelection(dl);
        var dt = this.createDefinitionTerm(dl);
        if (dtcontentcontainer.hasChildNodes()) {
            collapsetoend = true;
            while (dt.hasChildNodes()) {
                dt.removeChild(dt.firstChild);
            };
            while (dtcontentcontainer.hasChildNodes()) {
                dt.appendChild(dtcontentcontainer.firstChild);
            };
        };

        var selection = this.editor.getSelection();
        selection.selectNodeContents(dt);
        selection.collapse(collapsetoend);
    };

    this.createDefinitionTerm = function(dl, dd) {
        /* create a new definition term inside the current dl */
        var doc = this.editor.getInnerDocument();
        var dt = doc.createElement('dt');
        // somehow Mozilla seems to add breaks to all elements...
        if (dd) {
            if (dd.lastChild.nodeName.toLowerCase() == 'br') {
                dd.removeChild(dd.lastChild);
            };
        };
        // dd may be null here, if so we assume this is the first element in 
        // the dl
        if (!dd || dl == dd.lastChild) {
            dl.appendChild(dt);
        } else {
            var nextsibling = dd.nextSibling;
            if (nextsibling) {
                dl.insertBefore(dt, nextsibling);
            } else {
                dl.appendChild(dt);
            };
        };
        var nbsp = doc.createTextNode('\xa0');
        dt.appendChild(nbsp);
        var selection = this.editor.getSelection();
        selection.selectNodeContents(dt);
        selection.collapse();
        this.editor.getDocument().getWindow().focus();

        return dt;
    };

    this.createDefinition = function(dl, dt, initial_content) {
        var doc = this.editor.getInnerDocument();
        var dd = doc.createElement('dd');
        var nextsibling = dt.nextSibling;
        // somehow Mozilla seems to add breaks to all elements...
        if (dt) {
            if (dt.lastChild.nodeName.toLowerCase() == 'br') {
                dt.removeChild(dt.lastChild);
            };
        };
        while (nextsibling) {
            var name = nextsibling.nodeName.toLowerCase();
            if (name == 'dd' || name == 'dt') {
                break;
            } else {
                nextsibling = nextsibling.nextSibling;
            };
        };
        if (nextsibling) {
            dl.insertBefore(dd, nextsibling);
            //this._fixStructure(doc, dl, nextsibling);
        } else {
            dl.appendChild(dd);
        };
        if (initial_content) {
            for (var i=0; i < initial_content.length; i++) {
                dd.appendChild(initial_content[i]);
            };
        };
        var nbsp = doc.createTextNode('\xa0');
        dd.appendChild(nbsp);
        var selection = this.editor.getSelection();
        selection.selectNodeContents(dd);
        selection.collapse();
    };

    this.escapeFromDefinitionList = function(dl, currel, selNode) {
        var doc = this.editor.getInnerDocument();
        var p = doc.createElement('p');
        var nbsp = doc.createTextNode('\xa0');
        p.appendChild(nbsp);

        if (dl.lastChild == currel) {
            dl.parentNode.insertBefore(p, dl.nextSibling);
        } else {
            for (var i=0; i < dl.childNodes.length; i++) {
                var child = dl.childNodes[i];
                if (child == currel) {
                    var newdl = this.editor.getInnerDocument().createElement('dl');
                    while (currel.nextSibling) {
                        newdl.appendChild(currel.nextSibling);
                    };
                    dl.parentNode.insertBefore(newdl, dl.nextSibling);
                    dl.parentNode.insertBefore(p, dl.nextSibling);
                };
            };
        };
        currel.parentNode.removeChild(currel);
        var selection = this.editor.getSelection();
        selection.selectNodeContents(p);
        selection.collapse();
        this.editor.getDocument().getWindow().focus();
    };

    this._fixStructure = function(doc, dl, offsetnode) {
        /* makes sure the order of the elements is correct */
        var currname = offsetnode.nodeName.toLowerCase();
        var currnode = offsetnode.nextSibling;
        while (currnode) {
            if (currnode.nodeType == 1) {
                var nodename = currnode.nodeName.toLowerCase();
                if (currname == 'dt' && nodename == 'dt') {
                    var dd = doc.createElement('dd');
                    while (currnode.hasChildNodes()) {
                        dd.appendChild(currnode.childNodes[0]);
                    };
                    currnode.parentNode.replaceChild(dd, currnode);
                } else if (currname == 'dd' && nodename == 'dd') {
                    var dt = doc.createElement('dt');
                    while (currnode.hasChildNodes()) {
                        dt.appendChild(currnode.childNodes[0]);
                    };
                    currnode.parentNode.replaceChild(dt, currnode);
                };
            };
            currnode = currnode.nextSibling;
        };
    };
};

DefinitionListTool.prototype = new KupuTool;

