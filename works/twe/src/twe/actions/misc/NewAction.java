package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import java.awt.event.ActionEvent;
import twe.gui.*;
import java.io.*;
import javax.swing.text.html.*;

/**
 *
 * <p>Description: "New document" action</p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class NewAction
    extends AbstractAction
    implements TWAction {

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;

  public NewAction(JTextComponent editor) {

    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource(
        "twe/rsc/filenew.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("New document");

  }

  /**
   * getButton
   *
   * @return the button associated with the action
   */
  public JButton getButton() {
    return button;
  }

  /**
   * getIcon
   *
   * @return the icon for the action
   */
  public Icon getIcon() {
    return icon;
  }

  /**
   * getTextComponent
   *
   * @return the target text component of the action
   */
  public JTextComponent getTextComponent() {
    return editor;
  }

  /**
   * actionPerformed
   *
   * @param e ActionEvent
   */
  public void actionPerformed(ActionEvent e) {
    int test = JOptionPane.showConfirmDialog
        (editor, "Save your TWIki Document ?", "Save status",
         JOptionPane.YES_NO_CANCEL_OPTION);
    switch (test) {
      case 0: // Want to save
        new SaveAction(editor).actionPerformed(e);
        editor.setText("");
        ( (MainFrame) editor).initUndoRedo();
        break;
      case 1: // Don't want to save
        editor.setText("");
        ( (MainFrame) editor).initUndoRedo();
        ( (MainFrame) editor).setEditorKit(new HTMLEditorKit());

        break;
        case 2: break; // Cancel
    }
  }

}
