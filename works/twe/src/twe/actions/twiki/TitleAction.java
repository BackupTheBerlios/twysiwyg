package twe.actions.twiki;

import javax.swing.text.StyledEditorKit.*;
import twe.actions.*;
import javax.swing.*;
import java.awt.event.*;
import javax.swing.text.*;
import javax.swing.text.html.HTMLEditorKit.*;
import javax.swing.text.html.*;
import java.io.*;
import twe.gui.*;
import java.util.*;
import javax.swing.text.AbstractDocument.*;
import javax.swing.event.*;

public class TitleAction
    extends HTMLTextAction
    implements TWAction {
// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;

// Instance of HTML.Tag.IMPLIED HTML.Tag.H1 etc ...
  private HTML.Tag tag;
  /**
   * Constructs a new Title Action.
   */
  public TitleAction(int type) {
    super("T" + type);
    configForType(type);
  }

  private void configForType(int type){
    switch(type){
      case 0: tag = HTML.Tag.IMPLIED;break;
      case 1: tag = HTML.Tag.H1;break;
      case 2: tag = HTML.Tag.H2;break;
      case 3: tag = HTML.Tag.H3;break;
      case 4: tag = HTML.Tag.H4;break;
      case 5: tag = HTML.Tag.H5;break;
      case 6: tag = HTML.Tag.H6;break;
    }
    this.button = new JButton(this);

    // Retrieve resource from jar
    //      this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/t" + type + ".png"));
    //      this.button.setIcon(icon);

    this.button.setToolTipText(type==0?"Paragraph text":"Title of size " + type);
    }


  /**
   * getButton
   *
   * @return JButton
   */
  public JButton getButton() {
    return button;
  }

  /**
   * getIcon
   *
   * @return Icon
   */
  public Icon getIcon() {
    return null;
  }

  /**
   * getTextComponent
   *
   * @return JTextComponent
   */
  public JTextComponent getTextComponent() {
    return null;
  }

  /**
   * actionPerformed
   *
   * @param e ActionEvent
   */
  public void actionPerformed(ActionEvent e) throws ClassNotFoundException {
    JEditorPane editor = getEditor(e);
    HTMLDocument doc = (HTMLDocument) editor.getDocument();

    // the position for get corresponding element
    int pos = editor.viewToModel(editor.getCaret().getMagicCaretPosition());
    Element elem = doc.getParagraphElement(pos);

    AttributeSet attr = elem.getAttributes();
    Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);
    HTML.Tag name = null;
    if (nameAttribute instanceof HTML.Tag) {
      name = (HTML.Tag) nameAttribute;
    }
    Element first = doc.getParagraphElement(editor.getSelectionStart());
    int contentStart = elem.getStartOffset();
    int contentEnd = elem.getEndOffset();

    // if original tag is different of tag to apply
    if (name != tag) {
      SimpleAttributeSet sa = new SimpleAttributeSet();
      // Apply the tag action
      sa.addAttribute(StyleConstants.NameAttribute, tag);
      doc.setParagraphAttributes(contentStart, contentEnd - contentStart - 1,
                                 sa, true);
    }
    else {// change the attributes to implied which content text (no tag)
      SimpleAttributeSet sa = new SimpleAttributeSet();
      sa.addAttribute(StyleConstants.NameAttribute, HTML.Tag.IMPLIED);
      doc.setParagraphAttributes(contentStart, contentEnd - contentStart - 1,
                                 sa, true);
    }
    ((MainFrame)editor).updateDocTree();
    editor.requestFocus();
  }
}
