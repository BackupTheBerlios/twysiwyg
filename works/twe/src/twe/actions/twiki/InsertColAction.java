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
/**
 *
 * <p> </p>
 * <p>Description: Action for inserting a column after the caret's cell</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class InsertColAction
    extends AbstractAction implements TWAction{

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public InsertColAction(JTextComponent editor) {
      super("insert-col");
      this.editorPane = editor;
      // Retrieve resource from jar
      //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

      this.button = new JButton(this);
      this.button.setToolTipText("Insert column after current cell");
      //this.button.setIcon(icon);
    }




  public void actionPerformed(ActionEvent e) {
    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
    Element table = cur.getParentElement().getParentElement().getParentElement();
    int n = TWEUtil.getElementIndex(cur.getParentElement());
    for (int i = 0; i < table.getElementCount(); i++){
      try {
        // Get the n-th cell of a row (n = caret's cell) and append a cell to it
        Element curCol = table.getElement(i).getElement(n);
        doc.insertAfterEnd(curCol, "<td>  </td>");
      }
      catch (IOException ex) {
        ex.printStackTrace();
      }
      catch (BadLocationException ex) {
        ex.printStackTrace();
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
