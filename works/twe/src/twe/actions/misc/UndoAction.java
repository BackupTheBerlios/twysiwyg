package twe.actions.misc;

import javax.swing.*;
import java.awt.event.*;
import javax.swing.undo.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import twe.gui.*;

/**
 *
 * <p>Description: "Undo action" from Sun's example</p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class UndoAction
    extends AbstractAction
    implements TWAction {
  // icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;

  protected RedoAction redoAction;
  protected UndoManager undo;

  public UndoAction(UndoManager um, JTextComponent editor) {
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource(
        "twe/rsc/undo.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setEnabled(false);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Undo");

    this.undo = um;

  }

  public void actionPerformed(ActionEvent e) {
    try {
      undo.undo();

    }
    catch (CannotUndoException ex) {
      System.out.println("Unable to undo: " + ex);
      ex.printStackTrace();
    }
    updateUndoState();
    redoAction.updateRedoState();

    ((MainFrame)editor).updateDocTree();
   editor.requestFocus();

 }

  public void updateUndoState() {
    if (undo.canUndo()) {
      button.setEnabled(true);
    }
    else {
      button.setEnabled(false);
    }
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
    return icon;
  }

  /**
   * Set associated redo action. Must be set to perform an UndoAction
   * @param ua RedoAction
   */
  public void setRedoAction(RedoAction ra) {
    redoAction = ra;
  }

  /**
   * getTextComponent
   *
   * @return JTextComponent
   */
  public JTextComponent getTextComponent() {
    return editor;
  }
}
