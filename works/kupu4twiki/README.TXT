Kupu For TWiki
Version 1.0 beta (31/08/04)

Project Home Page : http://twiki.org/cgi-bin/view/Codev/KupuForTWiki
--------------------------------------------------------------------

What is Kupu ?
--------------

Kupu is a cross browser (Internet Explorer and Mozilla family) HTML editor
written in JavaScript. It is designed for integration in Content Management
Systems (CMS).

Features
--------

Aim of this project is to integrate Kupu in the TWiki web-based collaboration
platform for edition of topics.

Features implemented :
   - TWiki variables are rendered in green boxes
   - Internal links are rendered in blue boxes
   - Completion system to insert internal links
   - Attachments management is embedded in topic edition
   - Attachment reference insertion done by one click (image are shown, other files appears as links)
   - Extensible icons insertion browser
   - TWiki variables insertion facilities

Kupu is compatible with both IE and Mozilla but works better under Mozilla.

Prerequisites
-------------

In order to use Kupu with TWiki, following tools must be available :
   - TWiki Cairo+
   - Perl 5.6+
   - Java 1.4+


Install Kupu For TWiki
----------------------

1. Extract archive on a temporary directory.
   Directory include :
      - install.pl : installation script
      - bin/ : contains server-side scripts and a jar file for HTML -> TWikiML translation
      - lib/Kupu : contains library for kupu
      - _kupu/ : contains Kupu files
      - templates/ : contains Kupu templates (can be changed for Look&Feel)
      
2. Run installation script with the command : perl install.pl
   NB : Under Windows, launch script from cygwin
   
3. Modify TWiki templates to add a 'Kupu Edit' link in your pages.
   TWiki templates can be very differents, here is an example of line to add in your
   .tmpl files :
   <a href="%SCRIPTURLPATH%/kupuedit%SCRIPTSUFFIX%/%WEB%/%TOPIC%">Kupu Edit</a>

4. Modify .htaccess to add authorizations for kupuedit, twiki2html and html2twiki scripts.
   
