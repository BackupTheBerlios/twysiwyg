package twe.actions.twiki;

import javax.swing.*;
import java.awt.event.*;
import javax.swing.text.html.*;
import java.io.*;
import javax.swing.text.*;
import twe.actions.*;

/**
 *
 * <p>Description: Insert an horizontal line separator</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */

public class InsertSeparatorAction
    extends AbstractAction
    implements TWAction {

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public InsertSeparatorAction(JTextComponent editor) {
    super("insert-line");
    this.editorPane = editor;
    // Retrieve resource from jar
    //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

    this.button = new JButton(this);
    //this.button.setIcon(icon);
  }


  // insert the HR tag
  public void actionPerformed(ActionEvent ae) {
    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    try {

      doc.insertAfterEnd(doc.getCharacterElement(editorPane.
                                                 getCaretPosition()), "<hr>");
    }
    catch (IOException ex1) {
    }
    catch (BadLocationException ex1) {
    }
    editorPane.requestFocus();
  }

  /**
   * getIcon
   *
   * @return Icon
   */
  public Icon getIcon() {
    return icon;
  }

  /**
   * getTextComponent
   *
   * @return JTextComponent
   */
  public JTextComponent getTextComponent() {
    return editorPane;
  }

  /**
   * getButton
   *
   * @return JButton
   */
  public JButton getButton() {
    return button;
  }

  // }
  // updateActions();
}
