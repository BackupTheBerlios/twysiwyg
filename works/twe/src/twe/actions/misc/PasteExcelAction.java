package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import java.awt.event.*;
import twe.gui.*;
import java.awt.datatransfer.*;
import java.awt.*;
import java.io.*;
/**
 *
 * <p>Description: Past action derived from DefaultEditorKit </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class PasteExcelAction
    extends PasteAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;

  public PasteExcelAction(JTextComponent editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/editpaste.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Paste");

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

  public void actionPerformed(ActionEvent e){
    MainFrame ed = (MainFrame)editor;
    ed.getTwikiPane().setCaretPosition(0);
    Clipboard system = Toolkit.getDefaultToolkit().getSystemClipboard();
    Transferable t = system.getContents(null);
    try {
      if (t != null && t.isDataFlavorSupported(DataFlavor.stringFlavor)) {
        String text = (String)t.getTransferData(DataFlavor.stringFlavor);

      //if (text.startsWith("\t")){
          //System.out.println("ok");
          //text.replaceFirst("\t", "| |");
       // }

        text = text.replace('\t','|');
        text = text.replaceAll("\n","|\n|");
        text = "| " + text;
        text = text.replaceAll("\\|\\|","| |");
        if (text.endsWith("\n|"))
          text = text.substring(0,text.length() - 2);
        //text = text.substring(0,text.length()-2);
        //text = text.replaceAll("||","| |");
        ed.getTwikiPane().setText(text);
        ed.updateViews();
      }
    } catch (UnsupportedFlavorException ex) {
    } catch (IOException ex) {
    }


  }
}

