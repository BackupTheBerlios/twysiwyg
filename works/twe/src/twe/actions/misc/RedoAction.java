package twe.actions.misc;

import javax.swing.*;
import java.awt.event.*;
import javax.swing.undo.*;
import javax.swing.text.*;
import twe.actions.*;
import twe.gui.*;

/**
 *
 * <p>Description: "Redo action" from Sun's example</p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class RedoAction
      extends AbstractAction implements TWAction{
    // icon for the action
     private Icon icon;

// target editor for the action
     private JTextComponent editor;

// the button for the action
     private JButton button;
     protected UndoAction undoAction;
     protected UndoManager undo;

   public RedoAction(UndoManager um, JTextComponent editor) {
     // Retrieve resource from jar
     this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/redo.png"));
       this.editor = editor;
       this.button = new JButton(this);
       this.button.setEnabled(false);
       this.button.setIcon(icon);
       this.button.setText("");
       this.button.setToolTipText("Redo");

       this.undo = um;
     }


    public void actionPerformed(ActionEvent e) {
      try {
        undo.redo();
      }
      catch (CannotRedoException ex) {
        System.out.println("Unable to redo: " + ex);
        ex.printStackTrace();
      }
      updateRedoState();
      undoAction.updateUndoState();
      ((MainFrame)editor).updateDocTree();
      editor.requestFocus();
    }

    public void updateRedoState() {
        button.setEnabled(undo.canRedo());
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
   * Set associated undo action. Must be set to perform a RedoAction
   * @param ua UndoAction
   */
  public void setUndoAction(UndoAction ua){
    undoAction = ua;
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
