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
/**
 *
 * <p> </p>
 * <p>Description: Action for inserting a row under the caret's cell</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */

public class InsertRowAction
    extends AbstractAction
    implements TWAction {

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public InsertRowAction(JTextComponent editor) {
    super("insert-row");
    this.editorPane = editor;
    // Retrieve resource from jar
    //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

    this.button = new JButton(this);
    this.button.setToolTipText("Insert row under current cell");
  //this.button.setIcon(icon);
  }

  private String newRow(Element table) {
    int maxRow = 0;
    for (int i = 0; i < table.getElementCount() - 1; i++) {
      if (maxRow < table.getElement(i).getElementCount()) {
        maxRow = table.getElement(i).getElementCount();
      }
    }
    StringBuffer sb = new StringBuffer("<tr>");
    for (int i = 0; i < maxRow; i++) {
      sb.append("<td></td>");
    }
    sb.append("</tr>");
    return sb.toString();
  }

  /**
   * actionPerformed
   *
   * @param e ActionEvent
   */
  public void actionPerformed(ActionEvent e) {
    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
    Element table = cur.getParentElement().getParentElement().getParentElement();
    try {
      doc.insertAfterEnd(cur.getParentElement().getParentElement(), newRow(table));
    }
    catch (IOException ex) {
      ex.printStackTrace();
    }
    catch (BadLocationException ex) {
      ex.printStackTrace();
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
