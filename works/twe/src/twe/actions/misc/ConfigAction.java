package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import javax.swing.text.JTextComponent;
import twe.actions.*;
import java.awt.event.ActionEvent;
import twe.gui.*;
import java.awt.event.*;
import twe.util.*;
import java.util.prefs.*;
/**
 *
 * <p>Description: Copy action derived from DefaultEditorKit.CutAction </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class ConfigAction
    extends AbstractAction implements TWAction{


JDialog frame;
// icon for the action
  private Icon icon;

// target editor for the action
  private MainFrame control;

// the button for the action
  private JButton button;


  public ConfigAction(MainFrame editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/configure.png"));

    frame = new JDialog(editor.getMainFrame(),"Configure editor");

    this.control = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Configure editor");
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
    return control;
  }

  /**
   * actionPerformed
   *
   * @param e ActionEvent
   */
  public void actionPerformed(ActionEvent e) {
    ConfigurationDialog cd = new ConfigurationDialog(control.getMainFrame(),"Configure editor");
    Preferences prefs = control.getPrefs();
    if (prefs.getBoolean("AUTO_LOGIN",false)){
      cd.setName(prefs.get("WIKI_NAME", null));
      cd.setPass("*********************");
    }
    if (cd.showDialog(prefs.getBoolean("AUTO_LOGIN",false))){
      if (cd.getRemember()){
        prefs.put("WIKI_NAME",cd.getName());
        prefs.put("WIKI_PASS",cd.getPass());
        prefs.putBoolean("AUTO_LOGIN",true);

      }
      else {
        prefs.remove("WIKI_NAME");
        prefs.remove("WIKI_PASS");
        prefs.putBoolean("AUTO_LOGIN",false);

      }
      }
      control.requestFocus();
  }

}

