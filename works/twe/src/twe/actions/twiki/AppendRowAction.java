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
 * <p>Description: Add a row to current table (caret must be in a table)</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */

public class AppendRowAction
    extends AbstractAction implements TWAction{

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public AppendRowAction(JTextComponent editor) {
      super("append-row");
      this.editorPane = editor;
      // Retrieve resource from jar
      //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

      this.button = new JButton(this);
      this.button.setToolTipText("Append row");
      //this.button.setIcon(icon);
    }


/**
   * get the last cell of the table a given table cell belongs to
   *
   * @param cell  a cell of the table to get the last cell of
   * @return the Element having the last table cell
   */
  private Element getLastTableCell(Element cell) {
    Element table = cell.getParentElement().getParentElement();
    Element lastRow = table.getElement(table.getElementCount()-1);
    Element lastCell = lastRow.getElement(lastRow.getElementCount()-1);
    return lastCell;
  }

  /**
   * return an html string representing a new row according to number of column
   * of the table. The number of column is the max to avoid conflicts with spanned cols
   * @param table Element
   * @return String
   */
  private String newRow(Element table){
  int maxRow = 0;
  for (int i=0; i<table.getElementCount()-1; i++){
    if (maxRow < table.getElement(i).getElementCount())
      maxRow = table.getElement(i).getElementCount();
  }
  StringBuffer sb = new StringBuffer("<tr>");
  for (int i=0; i<maxRow; i++)
    sb.append("<td></td>");
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
    Element last = getLastTableCell(cur);
    Element table = cur.getParentElement().getParentElement().getParentElement();

    // Get the last tag of the table
    last = table.getElement(table.getElementCount()-1);

    try {
      doc.insertAfterEnd(last, newRow(table));
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
