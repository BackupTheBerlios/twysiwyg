package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import java.awt.event.*;
/**
 *
 * <p>Description: Cut action derived from DefaultEditorKit.CutAction </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWCutAction extends CutAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public TWCutAction(JTextComponent editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/editcut.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Cut");

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

