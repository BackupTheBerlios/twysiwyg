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
import twe.util.*;
import javax.swing.text.AbstractDocument.BranchElement;

/**
 *
 * <p> </p>
 * <p>Description: Toggle bullet or numbered list</p>
 * <p></p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class ToggleListAction
    extends HTMLTextAction
    implements TWAction {
// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;

  private String tag;
  private String openTag;
  private String closeTag;

  /**
   * Constructs a new Title Action.
   */
  public ToggleListAction(HTML.Tag tag) {
    super("toggle-" + tag.toString());
    this.tag = tag.toString();
    openTag = "<" + tag + ">";
    closeTag = "</" + tag + ">";

    //configForType(type);
    this.button = new JButton(this);

    // Retrieve resource from jar
    //      this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/t" + type + ".png"));
    //      this.button.setIcon(icon);

    this.button.setToolTipText("Bullet list");

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
    StringBuffer buf = new StringBuffer();
    buf.append(openTag);
    int start = editor.getSelectionStart();
    int end = editor.getSelectionEnd();
    Element first = doc.getParagraphElement(start);
    Element last = doc.getParagraphElement(end);
    BranchElement father = (BranchElement) first.getParentElement();


    if (father.getAttributes().getAttribute(StyleConstants.NameAttribute) ==
        HTML.Tag.LI &&
        (father.getParentElement().getAttributes().getAttribute(StyleConstants.NameAttribute) ==
        HTML.Tag.UL ||
        father.getParentElement().getAttributes().getAttribute(StyleConstants.NameAttribute) ==
        HTML.Tag.OL )) {
      int from = father.getParentElement().getStartOffset();
      int to = father.getParentElement().getEndOffset();
      Element ulElem = father.getParentElement();
      //Element ref = ulElem.getParentElement().getElement(TWEUtil.getElementIndex(ulElem) - 1);
//
        StringBuffer sb = new StringBuffer();
        sb.append("<p>");
        for (int i=0; i<ulElem.getElementCount(); i++){
          sb.append(TWEUtil.getElementText(ulElem.getElement(i), doc));
          sb.append("<p>");
        }
        try {
          //doc.remove(first.getStartOffset(), last.getEndOffset() - first.getStartOffset());
          //doc.insertAfterEnd(ref, sb.toString());
          doc.setOuterHTML(ulElem,sb.toString());
        }
        catch (IOException ex2) {
        }
        catch (BadLocationException ex2) {
        }
      /*SimpleAttributeSet sa = new SimpleAttributeSet();
      sa.addAttribute(StyleConstants.NameAttribute,HTML.Tag.CONTENT);
      doc.setParagraphAttributes(father.getStartOffset(),father.getEndOffset(),sa,true);
    */
 }
    else{
      for (int i = TWEUtil.getElementIndex(first);
           i <= TWEUtil.getElementIndex(last); i++) {
        buf.append("<li>");
        buf.append(TWEUtil.getElementText(father.getElement(i), doc));
        buf.append("</li>");
      }
      buf.append(closeTag);
      try {
        doc.remove(start, end - start);
        doc.insertBeforeStart(first, buf.toString());
      }
      catch (IOException ex1) {
      }
      catch (BadLocationException ex1) {
      }

      /*
          try {
            HTMLDocument tmp = new HTMLDocument();
            tmp.setParser(doc.getParser());



            tmp.insertAfterStart(tmp.getDefaultRootElement(), buf.toString());
            Element el = tmp.getDefaultRootElement().getElement(0);
            Element[] t = new Element[100];
            System.out.println(el.toString());
            t[0] = el;

//      doc.setOuterHTML(first,buf.toString());
          }
          catch (IOException ex1) {
          }
          catch (BadLocationException ex1) {
          }
          //father.replace(start,end-start,);
          SimpleAttributeSet sa = new SimpleAttributeSet();
          SimpleAttributeSet sa2 = new SimpleAttributeSet();
            // Apply the tag action
            //BranchElement newElem = new BranchElement(TWEUtil.getBodyElement(doc,(Element)null), sa2);
            //sa.addAttribute(StyleConstants.NameAttribute, HTML.Tag.UL);
//      sa.addAttribute(StyleConstants.NameAttribute, HTML.Tag.UL);
            sa2.addAttribute(StyleConstants.ComposedTextAttribute,HTML.Tag.UL);
            sa.addAttribute(StyleConstants.NameAttribute, HTML.Tag.LI);

            try {
           //   doc.insertString(start-1,"</ul>",sa2);
//        doc.setOuterHTML(first,"<ul>"+TWEUtil.getElementText(first,doc));
        //      doc.setOuterHTML(last,TWEUtil.getElementText(last,doc) + "</ul>");

              //((BranchElement)first.getParent()).replace();
//        doc.setPreservesUnknownTags(true);

//        doc.setParagraphAttributes(start, end - start - 1,sa, true);
              first = doc.getParagraphElement(editor.getSelectionStart());
              //doc.setOuterHTML(first,"<ul>" + TWEUtil.getElementText(first,doc) + "</ul>");

              //doc.insertBeforeStart(first,"<ul>");
                //doc.insertAfterEnd(first,"</ul>");
//        doc.insertBeforeEnd(last, "</ul>");
        //      doc.setParagraphAttributes(start, end - start - 1,
          //                             sa, false);

            System.out.println(first.getParentElement().getName());
//      ((BranchElement)first);
          }
            catch (Exception ex) {
            }



          AttributeSet attr = elem.getAttributes();
       Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);
          HTML.Tag name = null;
          if (nameAttribute instanceof HTML.Tag) {
            name = (HTML.Tag) nameAttribute;
          }
          int contentStart = elem.getStartOffset();
          int contentEnd = elem.getEndOffset();

          // if original tag is different of tag to apply
          if (name != tag) {

          }
          else {// change the attributes to implied which content text (no tag)
            SimpleAttributeSet sa = new SimpleAttributeSet();
            sa.addAttribute(StyleConstants.NameAttribute, HTML.Tag.IMPLIED);
       doc.setParagraphAttributes(contentStart, contentEnd - contentStart - 1,
                                       sa, true);
          }
          ((MainFrame)editor).updateDocTree();
       */
    }
    editor.requestFocus();
  }
}
