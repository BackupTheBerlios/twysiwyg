/*****************************************************************************
 *
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 *
 * This software is distributed under the terms of the Kupu
 * License. See LICENSE.txt for license text. For a list of Kupu
 * Contributors see CREDITS.txt.
 *
 *****************************************************************************/

// $Id: kupusourceedit.js,v 1.2 2004/10/30 18:22:12 romano Exp $

/*****************************************************************************
 * 
 * TWiki KupuEditorAddOn add-on for TWiki
 * Copyright (C) 2004 Damien Mandrioli and Romain Raugi
 *  
 * Modifications done for TWiki KupuEditorAddOn :
 * - 2004-10-24 - Source save ability
 * - 2004-10-09 - Translation in both directions 
 * - 2004-10-09 - SourceEditTool prototype 
 *  
 *****************************************************************************/

/* TWiki KupuEditorAddOn : SourceEditTool different prototype */
//function SourceEditTool(sourcebuttonid, sourceareaid) {
function SourceEditTool(sourcebuttonid, sourceareaid, htmltotwikitranslator, twikitohtmltranslator) {
/* -- End of modifications */

    /* Source edit tool to edit document's html source */
    this.sourceButton = document.getElementById(sourcebuttonid);
    this.sourceArea = document.getElementById(sourceareaid);
    /* TWiki KupuEditorAddOn : translators */
    this.htmltotwikitranslator = htmltotwikitranslator;
    this.twikitohtmltranslator = twikitohtmltranslator;
    /* -- End of modifications */
    
    this.initialize = function(editor) {
        /* attach the event handlers */
        this.editor = editor;
        addEventHandler(this.sourceButton, "click", this.switchSourceEdit, this);
        this.editor.logMessage('Source edit tool initialized');
    };
 
    this.switchSourceEdit = function(event) {
        var kupu = this.editor;
        var editorframe = kupu.getDocument().getEditable();
        var sourcearea = this.sourceArea;
        var kupudoc = kupu.getInnerDocument();
    
        if (editorframe.style.display != 'none') {
            // XXX why do we turn designMode on and off if we can't see the 
            // iframe anyway?
            if (kupu.getBrowserName() == 'Mozilla') {
                kupudoc.designMode = 'Off';
            };
            /* TWiki KupuEditorAddOn : TWiki translation and source save ability */
            //kupu._initialized = false;
            //var data = kupu.getInnerDocument().documentElement.getElementsByTagName('body')[0].innerHTML;
            var data = this.htmltotwikitranslator.translate(kupu.getInnerDocument().documentElement);
            var headNode = kupu.getInnerDocument().documentElement.getElementsByTagName("head")[0];
            var metaTags = kupu.getInnerDocument().documentElement.getElementsByTagName("meta");
            /* -- End of modifications */
            sourcearea.value = data;
            editorframe.style.display = 'none';
            sourcearea.style.display = 'block';
          } else {
            var data = sourcearea.value;
            /* TWiki KupuEditorAddOn : TWiki translation */
            //kupu.getInnerDocument().documentElement.getElementsByTagName('body')[0].innerHTML = data;
            var metaTags = kupu.getInnerDocument().documentElement.getElementsByTagName("meta");
            kupu.getInnerDocument().documentElement.getElementsByTagName('body')[0].innerHTML = this.twikitohtmltranslator.translate(data);
            metaTags.namedItem('view_permissions').setAttribute('content', this.twikitohtmltranslator.getViewPermissions());
            metaTags.namedItem('change_permissions').setAttribute('content', this.twikitohtmltranslator.getChangePermissions());
            /* -- End of modifications */
            sourcearea.style.display = 'none';
            editorframe.style.display = 'block';
            if (kupu.getBrowserName() == 'Mozilla') {
                kupudoc.designMode = 'On';
            };
            /* TWiki KupuEditorAddOn : TWiki translation */
            //kupu._initialized = true;
            /* -- End of modifications */
        };
     };
};

SourceEditTool.prototype = new KupuTool;

function MultiSourceEditTool(sourcebuttonid, textareaprefix) {
    /* Source edit tool to edit document's html source */
    this.sourceButton = document.getElementById(sourcebuttonid);
    this.textareaprefix = textareaprefix;

    this._currently_editing = null;

    this.initialize = function(editor) {
        /* attach the event handlers */
        this.editor = editor;
        addEventHandler(this.sourceButton, "click", this.switchSourceEdit, this);
        this.editor.logMessage('Source edit tool initialized');
    };

    this.switchSourceEdit = function(event) {
        var kupu = this.editor;
        if (!this._currently_editing) {
            var docobj = kupu.getDocument();
            var doc = docobj.getDocument();
            var editorframe = docobj.getEditable();
            var sourceareaid = this.textareaprefix + editorframe.id;
            var sourcearea = document.getElementById(sourceareaid);

            this._currently_editing = docobj;

            if (kupu.getBrowserName() == 'Mozilla') {
                doc.designMode = 'Off';
            };
            kupu._initialized = false;
            var data = doc.documentElement.
                            getElementsByTagName('body')[0].innerHTML;
            sourcearea.value = data;
            editorframe.style.display = 'none';
            sourcearea.style.display = 'block';
        } else {
            var docobj = this._currently_editing;
            var doc = docobj.getDocument();
            var editorframe = docobj.getEditable();
            var sourceareaid = this.textareaprefix + editorframe.id;
            var sourcearea = document.getElementById(sourceareaid);

            this._currently_editing = null;
            
            var data = sourcearea.value;
            doc.documentElement.
                    getElementsByTagName('body')[0].innerHTML = data;
            sourcearea.style.display = 'none';
            editorframe.style.display = 'block';
            if (kupu.getBrowserName() == 'Mozilla') {
                doc.designMode = 'On';
            };
            kupu._initialized = true;
        };
    };
};

MultiSourceEditTool.prototype = new KupuTool;

