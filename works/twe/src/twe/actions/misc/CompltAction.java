package twe.actions.misc;

import javax.swing.*;
import twe.gui.*;
import java.awt.*;
import java.awt.event.*;
import twe.util.*;
import java.util.*;
import javax.swing.event.*;
import javax.swing.text.html.*;
import javax.swing.text.*;


/**
* <p>Title: Completion System</p>
* <p>Description: </p>
* <p>Copyright: Copyright (c) 2004</p>
* <p>Company: </p>
* @author Romain Raugi modified by Damien Mandrioli
* @version 1.1
*/
public class CompltAction extends AbstractAction {
  // the root for completion tree
   private CpltTree root = new CpltTree(new ComplTopic("ROOT","","",""), null);

   private JPopupMenu complMenu = new JPopupMenu("Completion");

MainFrame editorPane;

public CompltAction(MainFrame mf){
  editorPane = mf;
// Create Popup
  complMenu.addPopupMenuListener(new PopupMenuListener() {
    public void popupMenuWillBecomeInvisible(PopupMenuEvent e) {
      complMenu.removeAll();
  }
  public void popupMenuWillBecomeVisible(PopupMenuEvent e) {}
  public void popupMenuCanceled(PopupMenuEvent e) {}
});
updateCplTree();
}

public void updateCplTree(){

    HashMap webs = new HashMap();
    String[] topics = editorPane.getWs().getTree();
//    if (topics == null)
  //    return;
    HashMap hm = new HashMap();
    CpltTree t, t2;
    if (topics == null)
      return;
    for (int i=0; i<topics.length; i++){

      String cweb;
      for (int j=0; j<topics[i].length(); j++){
        if (topics[i].charAt(j) == '.'){
          cweb = topics[i].substring(0, j);
          if (! webs.containsKey(cweb)){
            root.addChild(t2 = new CpltTree(new ComplTopic(cweb, "", "", ""), root));
            webs.put(cweb,t2);
            t2.addChild(new CpltTree(new ComplTopic(topics[i].substring(j+1), "", "", ""), root));
          }
          else{
            ((CpltTree)webs.get(cweb)).addChild(new CpltTree(new ComplTopic(topics[i].substring(j+1), "", "", ""), root));

          }
        }
      }
    }
   }

/**
 * Retrieve Topic's name from TextArea
 * @return String
 */
private String getTopicName() {
  boolean found = false;
  // Find caret position (or current selection)
  int caretPos = editorPane.getCaretPosition();
  if (caretPos > 0) {
    Element cur = ((HTMLDocument)editorPane.getDocument()).getParagraphElement(caretPos);
    String text = null;
    try {
      text =
          editorPane.getText(cur.getStartOffset(),
                         caretPos - cur.getStartOffset());
    }
    catch (BadLocationException ex) {
      ex.printStackTrace();
    }


    char l;
    int i = text.length() - 1;
    // Look for the whole string
    while (i > 0 && (! Character.isWhitespace(text.charAt(i)))) {
      i--;
    }
    if (Character.isWhitespace(text.charAt(i))) i++;
    return text.substring(i, text.length());
  }
  // No name found
  return "";
}

/**
 * Find caret position (or current selection)
 * @return int Caret Position or selection's end
 */
private int getCaretPosition() {
  int caretPos = editorPane.getAccessibleContext().getAccessibleText().getCaretPosition();
  if (caretPos <= 0) {
    caretPos = editorPane.getAccessibleContext().getAccessibleText().getSelectionEnd();
  }
  return caretPos;
}

/**
 * ~ Caret's absolute position
 * @param i int Caret position in text
 * @return Rectangle
 */
private Rectangle getCurrentBounds(int i) {
  return editorPane.getAccessibleContext().getAccessibleText().getCharacterBounds(i);
}

/**
 * Action linked to the key '.'
 * @param e ActionEvent
 */
public void actionPerformed(ActionEvent e) {

// Retrieve topic's name if there is one
  String name = getTopicName();
  CpltTree r = root.getNode(name);
  // There is one, looking for children topics
  if (r != null && ! r.isLeaf()) {
    JMenuItem jMenuItem;
    java.util.Iterator it = r.Iterator();
    while(it.hasNext()) {
      complMenu.add(jMenuItem = new JMenuItem(((CpltTree)it.next()).getTopic().getName()));
      jMenuItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          if (editorPane.getSelectedText() == "")
            System.out.println("append "+ ((JMenuItem)e.getSource()).getText());
            //editorPane.append(((JMenuItem)e.getSource()).getText());
          else
            editorPane.replaceSelection(((JMenuItem)e.getSource()).getText());
        }
      });
    }
    // Caret's absolute position
    int caretPos = getCaretPosition();
    if (2> 1){//caretPos > 0) {
      Rectangle rct = getCurrentBounds(caretPos);
      // Display menu at this position

      complMenu.show( (JEditorPane)e.getSource(), (int)rct.getX(), (int)rct.getY());
    }
  }
  // Add "." to the text
  if (editorPane.getSelectedText() == ""){}
  //  System.out.println("append point");
    //editorPane.append(".");
  else
    editorPane.replaceSelection(".");
}
}
