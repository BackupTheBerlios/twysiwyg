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
 * <p>Description: Add a column to current table (caret must be in a table)</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class AppendColAction
    extends AbstractAction implements TWAction{

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public AppendColAction(JTextComponent editor) {
      super("append-col");
      this.editorPane = editor;
      // Retrieve resource from jar
      //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

      this.button = new JButton(this);
      this.button.setToolTipText("Append column");
      //this.button.setIcon(icon);
    }


  public void actionPerformed(ActionEvent e) {
    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    Element cur = doc.getParagraphElement(editorPane.getCaretPosition());
    Element table = cur.getParentElement().getParentElement().getParentElement();
    for (int i = 0; i < table.getElementCount(); i++){
      try {
        // Get the last cell of a row and append a cell to it
        Element lastCol = table.getElement(i).getElement(table.getElement(i).getElementCount()-1);
        doc.insertAfterEnd(lastCol, "<td>  </td>");
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
   *
   * @return Icon
   */
  public Icon getIcon() {
    return null;
  }

  /**
   *
   * @return JTextComponent
   */
  public JTextComponent getTextComponent() {
    return null;
  }
}
