package twe.actions.twiki;

import javax.swing.text.StyledEditorKit.*;
import javax.swing.*;
import javax.swing.text.JTextComponent;
import twe.actions.*;
import java.awt.event.*;
/**
 *
 * <p>Description: Bold action derived from StyledEditorKit.BoldAction </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWBoldAction
    extends BoldAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public TWBoldAction(JTextComponent editor){
    super();
    // Retrieve resource from jar
  //  this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/bold.gif"));

    this.button = new JButton(this);

   // this.button.setIcon(icon);

    this.editor = editor;

//    this.button.setText("");
    this.button.setToolTipText("Bold");
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

