package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import java.awt.event.ActionEvent;
import twe.util.*;
import java.io.*;
import twe.gui.*;
/**
 *
 * <p>Description: "Save document" action </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class SaveAction
    extends AbstractAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public SaveAction(JTextComponent editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/filesave.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Save document");

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
    JFileChooser fc = new JFileChooser();
    fc.addChoosableFileFilter(new TwikiExtensionFilter());

    fc.showSaveDialog(editor);


      try {
        String fts; //file to save
        if (fc.getSelectedFile() == null) return;

        if (fc.getSelectedFile().getName().endsWith(".twiki"))
          fts = fc.getSelectedFile().getPath() + ".twiki";
        else
          fts = fc.getSelectedFile().getPath() + ".twiki";

        BufferedWriter out = new BufferedWriter(new FileWriter(fts));

        ((MainFrame)editor).updateViews();
        out.write(((MainFrame)editor).getTwikiPane().getText());
        out.close();
      }
      catch (IOException ex) {
}

    }





}

