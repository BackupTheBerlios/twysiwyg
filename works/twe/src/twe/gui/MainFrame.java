package twe.gui;

import java.io.*;
import java.util.*;
import java.util.prefs.*;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.text.*;
import javax.swing.text.DefaultEditorKit.*;
import javax.swing.text.html.*;
import javax.swing.text.html.HTML.*;
import javax.swing.tree.*;
import javax.swing.undo.*;

import twe.actions.misc.*;
import twe.actions.twiki.*;
import twe.translator.*;
import twe.util.*;

/**
 *
 * <p> </p>
 * <p>Description: Main class of TWiki WYSIWYG Editor</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class MainFrame
    extends JEditorPane {
  JFrame mainFrame = new JFrame();
  TWToolBar miscBar = new TWToolBar();
  // formating button tool bar n° 1
  TWToolBar formatBar = new TWToolBar();

  // formating button tool bar n° 2
  TWToolBar formatBar2 = new TWToolBar();

  // text field for status (bottom of frame)
  JTextField status = new JTextField("TWiki WISIWYG Editor");


  TitleAction contentAction;

  // Panel for tool bars
  JPanel barPanel = new JPanel();
  protected UndoAction undoAction;
  protected RedoAction redoAction;

  // Listener for undoable event
  MyUndoableEditListener undoListener;

  // Maping between document tree and element in html document
  HashMap treeElem = new HashMap();

//Panes to refresh from -> -1: nothing, 0 : wysiwyg, 1 : twiki, 2 : html
  private int updateState = 0;


  protected UndoManager undo = new UndoManager();

  // the reference of the topic being edited. format = Web.Topic
  protected String webTopic;

  // URL where TWiki service is installed
  protected String endPoint;

  // A reference to WYSIWYG editorpane
  JEditorPane editorPane;

  private JEditorPane htmlPane;
  private JEditorPane twikiPane;

  // The tree for document structure on the left
  private JTree docTree = new JTree(new DefaultMutableTreeNode("Document"));

  // the body element of HTML document
  private Element bodyElement;

  // Preferences of the editor. Associated with this class.
  // Use for password remembering
  private Preferences prefs = Preferences.userNodeForPackage(twe.gui.MainFrame.class);

  // The connection to the webservice
  WSConnection ws;

  /**
   *
   * @return JEditorPane which shows TWiki View
   */
  public JEditorPane getTwikiPane() {
    return twikiPane;
  }
  /**
   *
   * @return JEditorPane which shows HTML View
   */
  public JEditorPane getHtmlPane() {
    return htmlPane;
  }

  /**
   *
   * @return the main JFrame of the application
   */
  public JFrame getMainFrame() {
    return mainFrame;
  }

  /**
   *
   * @return the connection to WS associated with editor
   */
  public WSConnection getWs() {
    return ws;
  }

  /**
   *
   * @return topic as format "Web.Topic"
   */
  public String getWebTopic() {
    return webTopic;
  }
  /**
   *
   * @return url of the site where TWiki WS is installed
   */
  public String getEndPoint() {
    return endPoint;
  }

  /**
   *
   * @return preferences of the applications
   */
  public Preferences getPrefs() {
    return prefs;
  }



  /**
   * Constructor with params for connection with le server-side web service.
   * In online use, arguments for editor are passed by Web Start JNLP descriptor
   * @param endP url of site where TWiki service is installed
   * @param arg String which represent topic to edit
   */

  public MainFrame(String endP,String arg) {
    endPoint = endP;
    webTopic = arg;
    System.out.println("EndPoint : " + endPoint);
    System.out.println("Topic : " + arg);
    System.out.flush();

    // Instanciate editorpanes
    try {
      editorPane = this;
    }
    catch (Exception ex) {
      ex.printStackTrace();
    }
    htmlPane = new JEditorPane();

    twikiPane = new JEditorPane();

    editorPane.setEditable(true);

    initUndoRedo();

    // Functions that build buttons bars and the frame
    buildMiscBar();
    buildFormatBar();
    buildFormatBar2();
    buildFrame();


    // Create a listener for window events
    WindowListener listener = new WindowAdapter() {
      public void windowOpened(WindowEvent evt) {
      }

      public void windowClosing(WindowEvent evt) {
        if (ws != null) {
          ws.logout();
        }
        System.exit(0);
      }

      public void windowClosed(WindowEvent evt) {
      }
    };

    mainFrame.addWindowListener(listener);

    // Set size and position of the frame. Ratio : 3/4
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    int w = (int) screenSize.getWidth() * 3 / 4;
    int h = (int) screenSize.getHeight() * 3 / 4;
    int x = (int) (screenSize.getWidth() - w) / 2;
    int y = (int) (screenSize.getHeight() - h) / 2;

    mainFrame.setBounds(x, y, w, h);

    mainFrame.setVisible(true);

   configListeners();

   load();

  }

// Try to edit topic passed in param
  private void load() {

    ws = new WSConnection(this);
    if (webTopic != null) {
      ws.setTopicPath(webTopic);
      ws.login(null, null);
      ( (OpenAction) miscBar.getAction(OpenAction.class)).openFromTwikiString(
          ws.getTopicContent());
    }

    updateDocTree(); // update document tree on the left
    initCpl(); //Init Completion system
  }

// Build the first button bar
  private void buildMiscBar() {
    miscBar.addAction(new NewAction(editorPane));
    miscBar.addAction(new OpenAction(this));
    miscBar.addAction(new SaveAction(editorPane));
    miscBar.addSeparator();

    redoAction = new RedoAction(undo, this);
    undoAction = new UndoAction(undo, this);
    redoAction.setUndoAction(undoAction);
    undoAction.setRedoAction(redoAction);

    miscBar.addAction(undoAction);
    miscBar.addAction(redoAction);
    miscBar.addSeparator();
    miscBar.addAction(new TWCutAction(editorPane));
    miscBar.addAction(new TWCopyAction(editorPane));
    miscBar.addAction(new TWPasteAction(editorPane));
    //miscBar.addAction(new PasteExcelAction(editorPane));
    miscBar.addSeparator();
    miscBar.addAction(new SearchAction(this));
    miscBar.addAction(new ConfigAction(this));

    miscBar.addSeparator();
    miscBar.addAction(new UploadAction(this));

    miscBar.setFloatable(false);

    //    ( (OpenAction) miscBar.getAction(OpenAction.class)).openURL(new URL(
    //        "http://nefnet.org/page.html"));


    InputMap map = new InputMap();

    // Keystroke for Tabulation key (table movments,...)
    map.put(KeyStroke.getKeyStroke(KeyEvent.VK_TAB, 0), new TabAction());
    // KeyStroke for Enter key (add bullet, ...)
    map.put(KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0), new EnterAction());

    //map.put(KeyStroke.getKeyStroke(KeyEvent.VK_DELETE,0),null);

    map.setParent(getInputMap());
    this.setInputMap(JComponent.WHEN_FOCUSED, map);
    //this.setInputMap(JComponent.WHEN_FOCUSED,map);
    /*KeyStroke[] keys = this.getInputMap().allKeys();
         for (int i=0; i<keys.length; i++)
      if (keys[i].getKeyCode() == 9)
        this.getInputMap().remove(keys[i]);
         keys = this.getInputMap().allKeys();
         for (int i=0; i<keys.length; i++)
      System.out.println(keys[i].getKeyCode() + " " + keys[i].getModifiers());
     */
  }


  /**
   *
   * <p> </p>
   * <p>Description: Action for handling ENTER key
   * Add a bullet if caret is in a bullet list</p>
   * <p> </p>
   * <p> </p>
   * @author Damien Mandrioli
   * @version 1.0
   */
  public class EnterAction
      extends InsertBreakAction {


    /**
     * actionPerformed
     *
     * @param e ActionEvent
     */
    public void actionPerformed(ActionEvent e) {

      HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
      Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
      cur = cur.getParentElement();
      AttributeSet attr = cur.getAttributes();
      Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);

      // If caret in a bullet list
      if (nameAttribute == HTML.Tag.LI) {
        try {
          doc.insertAfterEnd(cur, "<li></li>");
          editorPane.setCaretPosition(TWEUtil.getNextElement(cur).getStartOffset());
        }
        catch (IOException ex) {
        }
        catch (BadLocationException ex) {
        }
      }
      else {
        super.actionPerformed(e);
      }
    }
  }
  /**
   *
   * <p> </p>
   * <p>Description: Action for handling TAB key
   * Special movements when carte is in table</p>
   * <p> </p>
   * @author Damien Mandrioli
   * @version 1.0
   */
  public class TabAction
      extends InsertTabAction {

    /**
     * actionPerformed
     *
     * @param e ActionEvent
     */
    public void actionPerformed(ActionEvent e) {
      HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
      Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
      cur = cur.getParentElement();
      AttributeSet attr = cur.getAttributes();
      Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);

      // If caret in a table
      if (nameAttribute == HTML.Tag.TD || nameAttribute == HTML.Tag.TH) {
        int curIndex = TWEUtil.getElementIndex(cur);
        // If current cell is not the last cell of current row
        if (curIndex < cur.getParentElement().getElementCount() - 1) {
          editorPane.setCaretPosition(cur.getParentElement().getElement(
              curIndex + 1).getStartOffset());
        }
        else {
          int parentIndex = TWEUtil.getElementIndex(cur.getParentElement());
          // current cell is in the last row, is it the last cell of the table ?
          if (parentIndex ==
              cur.getParentElement().getParentElement().getElementCount() - 1) {
            // Append row
            ( (InsertRowAction) formatBar.getAction(InsertRowAction.class)).
                actionPerformed(e);
            // go to first cell of next row
           editorPane.setCaretPosition(
               cur.getParentElement().getParentElement().getElement(
               parentIndex + 1).getElement(0).getStartOffset());

          }
          else {
            // go to first cell of next row
            editorPane.setCaretPosition(
                cur.getParentElement().getParentElement().getElement(
                parentIndex + 1).getElement(0).getStartOffset());
          }
        }
      }
      else {

        super.actionPerformed(e);
      }
    }
  }

  /**
   * Initialize the Undo/redo system
   * Called for nwe document
   */
  public void initUndoRedo() {
    undo.discardAllEdits();

    if (undoAction != null) {
      undoAction.updateUndoState();
    }
    if (redoAction != null) {
      redoAction.updateRedoState();
    }

    if (undoListener != null) { // there is an open document
      // Remove reference to the listener
      editorPane.getDocument().removeUndoableEditListener(undoListener);
    }
    // Create a new Listener in all cases
    undoListener = new MyUndoableEditListener();

    //Start watching for undoable edits and caret changes.
    editorPane.getDocument().addUndoableEditListener(undoListener);
  }

  // Build the format button bar
  private void buildFormatBar() {

    formatBar.addAction( contentAction = new TitleAction(0));
    formatBar.addAction(new TitleAction(1));
    formatBar.addAction(new TitleAction(2));
    formatBar.addAction(new TitleAction(3));
    formatBar.addAction(new TitleAction(4));
    formatBar.addAction(new TitleAction(5));
    formatBar.addAction(new TitleAction(6));
    formatBar.addSeparator();
    /*
        formatBar.addAction(new TWBoldAction(editorPane));
        formatBar.addAction(new TWItalicAction(editorPane));
        formatBar.addAction(new TWCodeAction(editorPane));
        // formatBar.addAction(new InsertTableAction(editorPane));

     */
    formatBar.addAction(new InsertSeparatorAction(this));
    formatBar.addAction(new InsertTableAction(this));
    formatBar.addAction(new AppendRowAction(this));
    formatBar.addAction(new AppendColAction(this));
    formatBar.addAction(new InsertRowAction(this));
    formatBar.addAction(new InsertColAction(this));
    formatBar.addAction(new RemoveRowAction(this));
    formatBar.addAction(new RemoveColAction(this));


    //    formatBar.addSeparator();


    formatBar.setFloatable(false);

  }

// Build the second format button bar
  private void buildFormatBar2() {

    formatBar2.addAction(new TWBoldAction(editorPane));
    formatBar2.addAction(new TWItalicAction(editorPane));
    formatBar2.addAction(new TWCodeAction(editorPane));
    formatBar2.addSeparator();
    /*formatBar2.addAction(new TWColorAction(this, Color.BLACK));
    formatBar2.addAction(new TWColorAction(this, Color.RED));
    formatBar2.addAction(new TWColorAction(this, Color.BLUE));
    formatBar2.addAction(new TWColorAction(this, Color.YELLOW));
    formatBar2.addAction(new TWColorAction(this, Color.GREEN));
    formatBar2.addAction(new TWColorAction(this, Color.ORANGE));
*/
  formatBar2.addSeparator();
    formatBar2.addAction(new ToggleListAction(HTML.Tag.UL));
    formatBar2.addAction(new ToggleListAction(HTML.Tag.OL));
    formatBar2.setFloatable(false);

  }


  /**
   * update 2 panes relatively to updateState variable
   */
  public void updateViews() {

    switch (updateState) {
      case 0: // Wysywyg changed
        htmlPane.setText(editorPane.getText());
        try {
          twikiPane.setText(HtmlToTwiki.translate(htmlPane.getText(), null, false));
        }
        catch (FileNotFoundException ex) {
          ex.printStackTrace();
        }
        catch (IOException ex) {
          ex.printStackTrace();
        }
        break;
      case 1: //TWiki changed
        editorPane.setText(TwikiToHtml.translate(twikiPane.getText()));
        htmlPane.setText(editorPane.getText());
        break;
      case 2: // HTML changed
        try {
          twikiPane.setText(HtmlToTwiki.translate(htmlPane.getText(), null, false));
          editorPane.setText(htmlPane.getText());
        }
        catch (FileNotFoundException ex1) {
          ex1.printStackTrace();
        }
        catch (IOException ex1) {
          ex1.printStackTrace();
        }
        }
            updateState = -1;
    }

    /**
     * Configure the listeners for document tree, movements in table
     */
    public void configListeners() {

      // WYSIWYG view listener
      editorPane.getDocument().addDocumentListener(new DocumentListener() {

        public void changedUpdate(DocumentEvent e) {
          updateDocTree();

          updateState = 0;
        }


        public boolean inTable(Element e) {
          HTML.Tag tag = (Tag) e.getAttributes().getAttribute(StyleConstants.
              NameAttribute);
          return (tag == Tag.TABLE || tag == Tag.TR || tag == Tag.TH ||
                  tag == Tag.TD);
        }

        public boolean inBullet(Element e) {
          HTML.Tag tag = (Tag) e.getAttributes().getAttribute(StyleConstants.
              NameAttribute);
          return (tag == Tag.LI);
        }


        public void insertUpdate(DocumentEvent e) {

          updateDocTree();
          updateState = 0;
          HTMLDocument doc = ( (HTMLDocument) editorPane.getDocument());

          Element cur = doc.getParagraphElement(e.getOffset()).getParentElement();
          // hack for better rendering the table during insertion of text
          if (inTable(cur)) {

            editorPane.repaint();
          }

        }

        public void removeUpdate(DocumentEvent e) {
          updateDocTree();

          updateState = 0;

          editorPane.repaint();
        }

      });
    // TWiki view listener
      twikiPane.getDocument().addDocumentListener(new DocumentListener() {

        public void changedUpdate(DocumentEvent e) {
          updateState = 1;
        }

        public void insertUpdate(DocumentEvent e) {
          updateState = 1;
        }

        public void removeUpdate(DocumentEvent e) {
          updateState = 1;
        }

      });
      // HTML view listener
      htmlPane.getDocument().addDocumentListener(new DocumentListener() {

        public void changedUpdate(DocumentEvent e) {
          updateState = 2;
        }

        public void insertUpdate(DocumentEvent e) {
          updateState = 2;
        }

        public void removeUpdate(DocumentEvent e) {
          updateState = 2;
        }

      });

    }

// Construct the GUI
    private void buildFrame() {

      mainFrame.setTitle("TWiki Editor");

      Container contentPane = mainFrame.getContentPane();
      contentPane.setLayout(new BorderLayout());

      GridLayout gl = new GridLayout(3, 1);

      JPanel toolBarPanel = new JPanel(gl);

      JTabbedPane tabPane = new JTabbedPane(JTabbedPane.BOTTOM);
      JScrollPane scrollEditor = new JScrollPane(editorPane);
      scrollEditor.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
      JScrollPane scrollHTML = new JScrollPane(htmlPane);
      JScrollPane scrollTwiki = new JScrollPane(twikiPane);

      // icons for tabbed panes (WYSIWYG, TWIKI, HTML)
      Icon icon = new ImageIcon(this.getClass().getClassLoader().getResource(
          "twe/rsc/wizard.png"));
      tabPane.addTab("WYSIWYG View", icon, scrollEditor,
                     "What You See Is What You Get");
      icon = new ImageIcon(this.getClass().getClassLoader().getResource(
          "twe/rsc/apply.png"));
      tabPane.addTab("TWiki View", icon, scrollTwiki, "TWiki syntax View");
      icon = new ImageIcon(this.getClass().getClassLoader().getResource(
          "twe/rsc/html.png"));
      tabPane.addTab("HTML View", icon, scrollHTML, "HTML View");


      initDocTree();

      JScrollPane treeScroll = new JScrollPane(docTree);

      //Create a split pane with the two scroll panes in it.
      JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
                                            treeScroll, tabPane);
      splitPane.setOneTouchExpandable(true);
      splitPane.setDividerLocation(150);

      // Update views when change of tabbed pane
      tabPane.addMouseListener(new MouseListener() {
        /**
         * mouseClicked
         *
         * @param e MouseEvent
         */

        public void mouseClicked(MouseEvent e) {
          updateViews();
        }

        /**
         * mouseEntered
         *
         * @param e MouseEvent
         */
        public void mouseEntered(MouseEvent e) {
        }

        /**
         * mouseExited
         *
         * @param e MouseEvent
         */
        public void mouseExited(MouseEvent e) {
        }

        /**
         * mousePressed
         *
         * @param e MouseEvent
         */
        public void mousePressed(MouseEvent e) {
        }

        /**
         * mouseReleased
         *
         * @param e MouseEvent
         */
        public void mouseReleased(MouseEvent e) {
        }
      });
      toolBarPanel.add(miscBar);
      toolBarPanel.add(formatBar);
      toolBarPanel.add(formatBar2);
      contentPane.add(toolBarPanel, BorderLayout.NORTH);

      contentPane.add(splitPane, BorderLayout.CENTER);

      status.setFont(new Font("Courier", 0, 12));
      contentPane.add(new JScrollPane(status), BorderLayout.SOUTH);
      htmlPane.setFont(new Font("Courier", 0, 14));
      twikiPane.setFont(new Font("Courier", 0, 14));

      editorPane.setContentType("text/html");

    }

    //This one listens for edits that can be undone.
    protected class MyUndoableEditListener
        implements UndoableEditListener {
      public void undoableEditHappened(UndoableEditEvent e) {
        //Remember the edit and update the menus.
        undo.addEdit(e.getEdit());
        undoAction.updateUndoState();
        redoAction.updateRedoState();
      }
    }


    /**
     * Set the log window text (bottom of frame)
     * @param s String
     */
    public void setLog(String s) {
      status.setText(s);
    }



    /**
     * Search for body element and init bodyElem variable
     * @param doc HTMLDocument
     * @param elem Element. set to null for recursive search on all document
     */
    public void setBodyElement(HTMLDocument doc, Element elem) {
      Element refElem;
      for (int i = 0; i < elem.getElementCount(); i++) {
        refElem = elem.getElement(i);
        AttributeSet attr = refElem.getAttributes();
        Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);
        if (nameAttribute == HTML.Tag.BODY) {
          bodyElement = refElem;
        }
        else {
          setBodyElement(doc, refElem);
        }
      }
    }

    /**
     * This function should not be use
     */
    private void beautify(){
      Element curElem;
       HTMLDocument doc = ((HTMLDocument)getDocument());
       setBodyElement(doc,doc.getDefaultRootElement());
       AttributeSet attr;
       Object nameAttribute;

       for (int i = 0; i < bodyElement.getElementCount(); i++) {

        curElem = bodyElement.getElement(i);
        attr = curElem.getAttributes();
        nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);

        if (nameAttribute == HTML.Tag.P) {
          SimpleAttributeSet sas = new SimpleAttributeSet();
          sas.addAttribute(StyleConstants.NameAttribute, Tag.BODY);
          doc.setParagraphAttributes(curElem.getStartOffset(),curElem.getEndOffset()-curElem.getStartOffset(),sas,true);
        }
      }

    }

    /**
     * Update the document tree
     */
    public void updateDocTree() {

      // Set the class variable bodyElement which represents the tag body
      // All the content of the document is child of body tag
      try {
        setBodyElement( ( (HTMLDocument) getDocument()),
                       getDocument().getDefaultRootElement());
      }
      catch (ClassCastException e) {
        e.printStackTrace();
        return;
      }
      Element curElem;
      DefaultMutableTreeNode refNode = new DefaultMutableTreeNode("Document");
      DefaultMutableTreeNode newNode = null;
      DefaultMutableTreeNode h1, h2, h3, h4, h5;
      h1 = h2 = h3 = h4 = h5 = refNode;
      AttributeSet attr;
      Object nameAttribute;

      // Construct the document tree and associate leaf with elements
      // for document navigation
      for (int i = 0; i < bodyElement.getElementCount(); i++) {

        curElem = bodyElement.getElement(i);
//        System.out.println(curElem.getName());
        attr = curElem.getAttributes();
        nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);

        if (nameAttribute == HTML.Tag.H1) {

          newNode =
              new DefaultMutableTreeNode(TWEUtil.getElementText(curElem, getDocument()));
          refNode.add(newNode);
          treeElem.put(newNode, curElem);
          h1 = h2 = h3 = h4 = h5 = newNode;
        }
        else if (nameAttribute == HTML.Tag.H2) {
          newNode = new DefaultMutableTreeNode(TWEUtil.getElementText(curElem,
              getDocument()));
          h1.add(newNode);
          treeElem.put(newNode, curElem);
          h2 = h3 = h4 = h5 = newNode;
        }
        else if (nameAttribute == HTML.Tag.H3) {
          newNode = new DefaultMutableTreeNode(TWEUtil.getElementText(curElem,
              getDocument()));
          h2.add(newNode);
          treeElem.put(newNode, curElem);
          h3 = h4 = h5 = newNode;
        }
        else if (nameAttribute == HTML.Tag.H4) {
          newNode = new DefaultMutableTreeNode(TWEUtil.getElementText(curElem,
              getDocument()));
          h3.add(newNode);
          treeElem.put(newNode, curElem);

          h4 = h5 = newNode;
        }
        else if (nameAttribute == HTML.Tag.H5) {
          newNode = new DefaultMutableTreeNode(TWEUtil.getElementText(curElem,
              getDocument()));
          h4.add(newNode);
          treeElem.put(newNode, curElem);
          h5 = newNode;
        }
        else if (nameAttribute == HTML.Tag.H6) {
          newNode = new DefaultMutableTreeNode(TWEUtil.getElementText(curElem,
              getDocument()));
          h5.add(newNode);
          treeElem.put(newNode, curElem);
        }

      }



      DefaultTreeModel dtm = new DefaultTreeModel(refNode);

      docTree.setModel(dtm);

      for (int i = 0; i < docTree.getRowCount(); i++) {
        docTree.expandRow(i);
      }
      DefaultTreeCellRenderer cr = (DefaultTreeCellRenderer) docTree.
          getCellRenderer();
      cr.setClosedIcon(null); //new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/right.png")));
      cr.setOpenIcon(null); //new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/down.png")));
      cr.setLeafIcon(null); //new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/right.png")));

    }

    /**
     * Initialize the document tree
     */
    public void initDocTree() {
    //  docTree = new JTree();
      docTree.setRootVisible(true);

      // Listener for clicks on document tree
      docTree.addMouseListener(new MouseListener() {
        public void mouseClicked(MouseEvent e) {
          TreePath tp = docTree.getSelectionPath();
          Object[] leafs = tp.getPath();
          // get in the hashmap treeLeaf -> Element the selected element
          // to put the caret
          Element elem = (Element) treeElem.get(leafs[leafs.length - 1]);
          if (elem != null) {
            editorPane.setSelectionStart(elem.getStartOffset());
            editorPane.setSelectionEnd(elem.getStartOffset());
          }
          editorPane.requestFocus();
        }

        public void mouseEntered(MouseEvent e) {}

        public void mouseExited(MouseEvent e) {}

        public void mousePressed(MouseEvent e) {}

        public void mouseReleased(MouseEvent e) {}
      });
    }

    /**
     * Initialize completion system
     */
    public void initCpl() {
      // Affect action for key '.'
      Keymap kmap = editorPane.getKeymap();
      kmap.addActionForKeyStroke(KeyStroke.getKeyStroke('.'),
                                 (Action)new CompltAction(this));

    }

    /**
     * Create a MainFrame object with params.
     * First param should be url of server where TWiki service is installed
     * @param args String[]
     * @throws IOException
     */
    public static void main(String[] args) throws IOException {
      if (args.length > 1) {
        new MainFrame(args[0],args[1]);
      }
      else {
        //Standalone mode
        new MainFrame(null,null);
      }
    }


  }
