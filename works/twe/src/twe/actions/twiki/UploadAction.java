package twe.actions.twiki;



import javax.swing.*;
import java.awt.event.*;
import javax.swing.text.html.*;
import java.io.*;
import javax.swing.text.*;
import twe.actions.*;
import twe.gui.*;
/**
 *
 * <p>Description: Try to remotely save the topic</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */

public class UploadAction
    extends AbstractAction
    implements TWAction {

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;

  public UploadAction(JTextComponent editor) {
    super("upload");
    this.editorPane = editor;
    // Retrieve resource from jar
      this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/up.png"));

    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Upload topic");

  }


  public void actionPerformed(ActionEvent ae) {
    MainFrame edit = (MainFrame) editorPane;
    edit.updateViews();
    edit.getWs().setTopicContent(edit.getTwikiPane().getText());

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
   * getTextComponent
   *
   * @return JTextComponent
   */
  public JTextComponent getTextComponent() {
    return editorPane;
  }

  /**
   * getButton
   *
   * @return JButton
   */
  public JButton getButton() {
    return button;
  }

  // }
  // updateActions();
}
