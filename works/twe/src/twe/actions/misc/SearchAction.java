package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import twe.gui.*;
import javax.swing.text.JTextComponent;
import java.awt.event.ActionEvent;
import javax.swing.text.*;
import java.awt.*;
import javax.swing.text.html.*;
import javax.swing.text.html.HTMLEditorKit.*;
/**
 *
 * <p>Description: "Search" action </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class SearchAction
    extends HTMLTextAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public SearchAction(JTextComponent editor){
    super("search");
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/filefind.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Search");

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
    MainFrame ed = ((MainFrame)editor);
   // ed.beautify();
  }

}

