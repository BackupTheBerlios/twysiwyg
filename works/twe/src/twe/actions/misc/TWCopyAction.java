package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import javax.swing.text.JTextComponent;
import twe.actions.*;
import java.awt.event.*;
/**
 *
 * <p>Description: Copy action derived from DefaultEditorKit.CutAction </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWCopyAction
    extends CutAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public TWCopyAction(JTextComponent editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/editcopy.png"));


    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Copy");
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

  public void actionPerformed(ActionEvent ae){
      super.actionPerformed(ae);
      editor.requestFocus();

    }

}

