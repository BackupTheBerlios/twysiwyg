package twe.actions.twiki;

import javax.swing.text.StyledEditorKit.*;
import javax.swing.*;
import javax.swing.text.JTextComponent;
import twe.actions.*;
import java.awt.event.*;
/**
 *
 * <p>Description: Italic action derived from StyledEditorKit.ItalicAction </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWItalicAction
    extends ItalicAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public TWItalicAction(JTextComponent editor){
    super();
    // Retrieve resource from jar
   // this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/italic.gif"));
    this.button = new JButton(this);
   // this.button.setIcon(icon);

    this.editor = editor;


    this.button.setToolTipText("Italic");
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

