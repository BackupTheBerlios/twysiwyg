package twe.actions.twiki;

import javax.swing.text.*;
import javax.swing.text.html.HTMLEditorKit.*;
import javax.swing.text.html.*;
import twe.actions.*;
import javax.swing.JButton;
import javax.swing.Icon;
import javax.swing.*;
import java.awt.event.*;
import java.io.*;
import twe.util.*;
import javax.swing.text.AbstractDocument.DefaultDocumentEvent;
import javax.swing.event.DocumentEvent.EventType;
import javax.swing.text.AbstractDocument.ElementEdit;
import javax.swing.undo.UndoableEdit;

/**
 *
 * <p> </p>
 * <p>Description: Action for deleting the column of caret's cell</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class RemoveColAction
    extends AbstractAction
    implements TWAction {

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public RemoveColAction(JTextComponent editor) {
    super("del-col");
    this.editorPane = editor;
    // Retrieve resource from jar
    //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

    this.button = new JButton(this);
    this.button.setToolTipText("Remove column");
    //this.button.setIcon(icon);
  }



  public void actionPerformed(ActionEvent e) {
    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
    Element table = cur.getParentElement().getParentElement().getParentElement();
    int n = TWEUtil.getElementIndex(cur.getParentElement());
    //doc.dump(System.out);
    // Last col case (doesn't work like others)

    if (n == cur.getParentElement().getParentElement().getElementCount() - 1) {
      int size = table.getElementCount();

      for (int i = table.getElementCount()-1; i >=0; i--) {
        try {
          // Get the n-th cell of a row (n = caret's cell) and delete it
          Element curCol = table.getElement(i).getElement(n);
          //System.out.println(table.getElementCount() + " o " + i + TWEUtil.getElementText(curCol,doc) );

          //curCol = curCol.getParentElement() ;
          doc.remove(curCol.getStartOffset(),
                     curCol.getEndOffset() - curCol.getStartOffset()-1);

        }
        catch (BadLocationException ex1) {
          ex1.printStackTrace() ;
        }
      }

    }
    else {
      int size = table.getElementCount();
      for (int i = 0; i < size; i++) {
        try {
          // Get the n-th cell of a row (n = caret's cell) and delete it
          Element curCol = table.getElement(i).getElement(n);
          //System.out.println(table.getElementCount() + " o " + i + TWEUtil.getElementText(curCol,doc) );
          doc.remove(curCol.getStartOffset(),
                     curCol.getEndOffset() - curCol.getStartOffset());
        }
        catch (BadLocationException ex) {
          ex.printStackTrace();
        }
      }
    }
    editorPane.requestFocus();
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
}
