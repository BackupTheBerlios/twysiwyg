/*****************************************************************************
 *
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 *
 * This software is distributed under the terms of the Kupu
 * License. See LICENSE.txt for license text. For a list of Kupu
 * Contributors see CREDITS.txt.
 *
 *****************************************************************************/

// $Id: kupuinit.js,v 1.3 2004/12/18 17:40:27 romano Exp $

/*****************************************************************************
 * 
 * TWiki KupuEditorAddOn add-on for TWiki
 * Copyright (C) 2004 Damien Mandrioli and Romain Raugi
 *  
 * Modifications done for TWiki KupuEditorAddOn :
 * - 2004-10-04 - TWiki specific tools Kupu registering
 * - 2004-10-04 - Kupu base tools unregistering (Properties, Links, Images)
 * - 2004-12-18 - KupuEditor Instanciation
 * - 2004-10-09 - Translators instanciation 
 *  
 *****************************************************************************/

//----------------------------------------------------------------------------
// Sample initialization function
//----------------------------------------------------------------------------

function initKupu(iframe) {
    /* Although this is meant to be a sample implementation, it can
        be used out-of-the box to run the sample pagetemplate or for simple
        implementations that just don't use some elements. When you want
        to do some customization, this should probably be overridden. For 
        larger customization actions you will have to subclass or roll your 
        own UI object.
    */

    // first we create a logger
    var l = new PlainLogger('kupu-toolbox-debuglog', 5);
    
    // now some config values
    var conf = loadDictFromXML(document, 'kupuconfig');
    
    // the we create the document, hand it over the id of the iframe
    var doc = new KupuDocument(iframe);
    
    /* TWiki KupuEditorAddOn translator tools */
    var html2twikitranslatortool = new HtmlToTwikiTranslatorTool(conf.html2twiki);
    var twiki2htmltranslatortool = new TwikiToHtmlTranslatorTool(conf.twiki2html);
    
    // now we can create the controller
    /* TWiki KupuEditorAddOn : modified KupuEditor instanciation */
    //var kupu = new KupuEditor(doc, conf, l);
    var kupu = new KupuEditor(doc, conf, l, html2twikitranslatortool, twiki2htmltranslatortool);
    /* -- End of modifications */

    var contextmenu = new ContextMenu();
    kupu.setContextMenu(contextmenu);

    // now we can create a UI object which we can use from the UI
    var ui = new KupuUI('kupu-tb-styles');

    // the ui must be registered to the editor like a tool so it can be notified
    // of state changes
    kupu.registerTool('ui', ui); // XXX Should this be a different method?

    // add the buttons to the toolbar
          
    var savebuttonfunc = function(button, editor) {
      editor.saveDocument(conf.redirect)
    };
    var savebuttonfunc = function(button, editor) {editor.saveDocument()};
    
    var savebutton = new KupuButton('kupu-save-button', savebuttonfunc);
    kupu.registerTool('savebutton', savebutton);

    // function that returns a function to execute a button command
    var execCommand = function(cmd) {
        return function(button, editor) {
            editor.execCommand(cmd);
        };
    };

    var boldchecker = ParentWithStyleChecker(new Array('b', 'strong'),
					     'font-weight', 'bold');
    var boldbutton = new KupuStateButton('kupu-bold-button', 
                                         execCommand('bold'),
                                         boldchecker,
                                         'kupu-bold',
                                         'kupu-bold-pressed');
    kupu.registerTool('boldbutton', boldbutton);

    var italicschecker = ParentWithStyleChecker(new Array('i', 'em'),
						'font-style', 'italic');
    var italicsbutton = new KupuStateButton('kupu-italic-button', 
                                           execCommand('italic'),
                                           italicschecker, 
                                           'kupu-italic', 
                                           'kupu-italic-pressed');
    kupu.registerTool('italicsbutton', italicsbutton);

    var underlinechecker = ParentWithStyleChecker(new Array('u'));
    var underlinebutton = new KupuStateButton('kupu-underline-button', 
                                              execCommand('underline'),
                                              underlinechecker,
                                              'kupu-underline', 
                                              'kupu-underline-pressed');
    kupu.registerTool('underlinebutton', underlinebutton);

    var subscriptchecker = ParentWithStyleChecker(new Array('sub'));
    var subscriptbutton = new KupuStateButton('kupu-subscript-button',
                                              execCommand('subscript'),
                                              subscriptchecker,
                                              'kupu-subscript',
                                              'kupu-subscript-pressed');
    kupu.registerTool('subscriptbutton', subscriptbutton);

    var superscriptchecker = ParentWithStyleChecker(new Array('super', 'sup'));
    var superscriptbutton = new KupuStateButton('kupu-superscript-button', 
                                                execCommand('superscript'),
                                                superscriptchecker,
                                                'kupu-superscript', 
                                                'kupu-superscript-pressed');
    kupu.registerTool('superscriptbutton', superscriptbutton);

    var justifyleftbutton = new KupuButton('kupu-justifyleft-button',
                                           execCommand('justifyleft'));
    kupu.registerTool('justifyleftbutton', justifyleftbutton);

    var justifycenterbutton = new KupuButton('kupu-justifycenter-button',
                                             execCommand('justifycenter'));
    kupu.registerTool('justifycenterbutton', justifycenterbutton);

    var justifyrightbutton = new KupuButton('kupu-justifyright-button',
                                            execCommand('justifyright'));
    kupu.registerTool('justifyrightbutton', justifyrightbutton);

    var outdentbutton = new KupuButton('kupu-outdent-button', execCommand('outdent'));
    kupu.registerTool('outdentbutton', outdentbutton);

    var indentbutton = new KupuButton('kupu-indent-button', execCommand('indent'));
    kupu.registerTool('indentbutton', indentbutton);

    var undobutton = new KupuButton('kupu-undo-button', execCommand('undo'));
    kupu.registerTool('undobutton', undobutton);

    var redobutton = new KupuButton('kupu-redo-button', execCommand('redo'));
    kupu.registerTool('redobutton', redobutton);

    var removeimagebutton = new KupuRemoveElementButton('kupu-removeimage-button',
							'img',
							'kupu-removeimage');
    kupu.registerTool('removeimagebutton', removeimagebutton);
    var removelinkbutton = new KupuRemoveElementButton('kupu-removelink-button',
						       'a',
						       'kupu-removelink');
    kupu.registerTool('removelinkbutton', removelinkbutton);

    // add some tools
    // XXX would it be better to pass along elements instead of ids?
    var colorchoosertool = new ColorchooserTool('kupu-forecolor-button',
                                                'kupu-hilitecolor-button',
                                                'kupu-colorchooser');
    kupu.registerTool('colorchooser', colorchoosertool);

    var listtool = new ListTool('kupu-list-ul-addbutton',
                                'kupu-list-ol-addbutton',
                                'kupu-ulstyles', 'kupu-olstyles');
    kupu.registerTool('listtool', listtool);
    
    var definitionlisttool = new DefinitionListTool('kupu-list-dl-addbutton');
    kupu.registerTool('definitionlisttool', definitionlisttool);
    
    /* TWiki KupuEditorAddOn : no properties panel */   
    //var proptool = new PropertyTool('kupu-properties-title', 'kupu-properties-description');
    //kupu.registerTool('proptool', proptool);

    /* TWiki KupuEditorAddOn : no URL link panel */   
    //var linktool = new LinkTool();
    //kupu.registerTool('linktool', linktool);
    //var linktoolbox = new LinkToolBox("kupu-link-input", "kupu-link-button", 'kupu-toolbox-links', 'kupu-toolbox', 'kupu-toolbox-active');
    //linktool.registerToolBox('linktoolbox', linktoolbox);

    /* TWiki KupuEditorAddOn : no images panel */   
    //var imagetool = new ImageTool();
    //kupu.registerTool('imagetool', imagetool);
    //var imagetoolbox = new ImageToolBox('kupu-image-input', 'kupu-image-addbutton', 
    //                                    'kupu-image-float-select', 'kupu-toolbox-images', 
    //                                    'kupu-toolbox', 'kupu-toolbox-active');
    //imagetool.registerToolBox('imagetoolbox', imagetoolbox);

    var tabletool = new TableTool();
    kupu.registerTool('tabletool', tabletool);
    var tabletoolbox = new TableToolBox('kupu-toolbox-addtable', 
        'kupu-toolbox-edittable', 'kupu-table-newrows', 'kupu-table-newcols',
        'kupu-table-makeheader', 'kupu-table-classchooser', 'kupu-table-alignchooser',
        'kupu-table-addtable-button', 'kupu-table-addrow-button', 'kupu-table-delrow-button', 
        'kupu-table-addcolumn-button', 'kupu-table-delcolumn-button', 
        'kupu-table-fix-button', 'kupu-table-fixall-button', 'kupu-toolbox-tables',
        'kupu-toolbox', 'kupu-toolbox-active'
        );
    tabletool.registerToolBox('tabletoolbox', tabletoolbox);

    var showpathtool = new ShowPathTool();
    kupu.registerTool('showpathtool', showpathtool);

    var sourceedittool = new SourceEditTool('kupu-source-button',
                                            'kupu-editor-textarea');
    kupu.registerTool('sourceedittool', sourceedittool);
    
    // register some cleanup filter
    // remove tags that aren't in the XHTML DTD
    var nonxhtmltagfilter = new NonXHTMLTagFilter();
    kupu.registerFilter(nonxhtmltagfilter);

//----------------------------------------------------------------------------
// TWiki KupuEditorAddOn Tools
//----------------------------------------------------------------------------
 
    // TWiki KupuEditorAddOn Links tool
    var linktool = new TWikiLinkTool(conf.current_web);
    kupu.registerTool('linktool', linktool);
    var linktoolbox = new TWikiLinkToolBox('kupu-toolbox-options', 
                                           'switch-options', 
                                           'kupu-toolbox-target', 
                                           'switch-target', 
                                           'div-current-web', 
                                           'div-all-web', 
                                           'div-external', 
                                           'linkCurrentWeb', 
                                           'linkAllWeb', 
                                           'linkExternal', 
                                           'current-web-select', 
                                           'all-web-select', 
                                           'kupu-link-input', 
                                           'kupu-link-button', 
                                           'kupu-toolbox-links', 
                                           'kupu-toolbox-addlink', 
                                           'link-catch-option', 
                                           'link-completion-option', 
                                           'kupu-toolbox', 
                                           'kupu-toolbox-active');
    linktool.registerToolBox('linktoolbox', linktoolbox);
    
    // TWiki KupuEditorAddOn Attachments tool
    var attachmentstool = new TWikiAttachListTool();
    kupu.registerTool('attachmentstool', attachmentstool);
    var attachmentstoolbox = new TWikiAttachListToolBox('kupu-attachments-iframe', 
                                                        'kupu-toolbox', 
                                                        'kupu-toolbox-active');
    attachmentstool.registerToolBox('attachmenttoolbox', attachmentstoolbox);
    
    // TWiki KupuEditorAddOn Images tool
    var twikiimagestool = new TWikiImagesTool('kupu-twikiicons-button', 
                                              'kupu-twikiicons');
    kupu.registerTool('twikiimage', twikiimagestool);
    
    // TWiki KupuEditorAddOn Variables tools
    var removevarbutton = new KupuRemoveElementButton('kupu-removevar-button',
						                                          'span',
						                                          'kupu-removevar');
    kupu.registerTool('removevarbutton', removevarbutton);
    
    var twikivartool = new TWikiVarTool();
    kupu.registerTool('twikivartool', twikivartool);
    var twikivartoolbox = new TWikiVarToolBox('twiki-var-select', 
                                              'twiki-var-button', 
                                              'kupu-toolbox', 
                                              'kupu-toolbox-active');
    twikivartool.registerToolBox('twikivartoolbox', twikivartoolbox);
    
    // TWiki KupuEditorAddOn Permissions tool
    var permstool = new TWikiPermsTool('kupu-perms-selector', 
                                       'perm-header', 
                                       'view-perms', 
                                       'change-perms', 
                                       'input-perms', 
                                       'list-perms', 
                                       'remove-perms', 
                                       'perms-close');
    kupu.registerTool('permstool', permstool);
    
    // TWiki KupuEditorAddOn "rollover" tool for panels
    var rollingtool = new TWikiRollingTool(new Array(
                                           'links-title',
                                           'variables-title',
                                           'attachments-title',
                                           'tables-title',
                                           'permissions-title',
                                           'debug-title'));
    kupu.registerTool('rollingtool', rollingtool);

    return kupu;
};
