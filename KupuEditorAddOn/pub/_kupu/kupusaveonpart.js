/*****************************************************************************
 *
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 *
 * This software is distributed under the terms of the Kupu
 * License. See LICENSE.txt for license text. For a list of Kupu
 * Contributors see CREDITS.txt.
 *
 *****************************************************************************/

// $Id: kupusaveonpart.js,v 1.1 2004/10/10 19:13:19 romano Exp $

function saveOnPart() {
    /* ask the user if (s)he wants to save the document before leaving */
    if (kupu.content_changed && 
        confirm('You have unsaved changes. Do you want to save before leaving the page?')) {
        kupu.config.reload_src = 0;
        kupu.saveDocument(false, true);
    };
};
