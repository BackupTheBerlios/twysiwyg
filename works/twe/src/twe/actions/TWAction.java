package twe.actions;

import javax.swing.*;
import javax.swing.text.*;
/**
 *
 * <p> </p>
 * <p>Description: Interface for actions on TWE. Abstractly, an action
*  is formed by icon a controler and a button, should be extended or derived</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public interface TWAction {

  /**
   * return an Icon which typically appear on the button (see getButton)
   * @return Icon
   */
  Icon getIcon();

  /**
   * return the controler for the action, typically a MainFrame object
   * @return JTextComponent
   */
  JTextComponent getTextComponent();

  /**
   * return the button for the action for contructions of button bars
   * @return JButton
   */
  JButton getButton();
}
