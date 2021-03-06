/*****************************************************************************
 *
 * Copyright (c) 2003-2004 Kupu Contributors. All rights reserved.
 *
 * This software is distributed under the terms of the Kupu
 * License. See LICENSE.txt for license text. For a list of Kupu
 * Contributors see CREDITS.txt.
 *
 *****************************************************************************/

// $Id: kupustart_form.js,v 1.1 2004/10/10 19:13:20 romano Exp $

function startKupu() {
    var frame = document.getElementById('kupu-editor'); 
    var kupu = initKupu(frame);
    kupu.initialize();

    return kupu;
};
