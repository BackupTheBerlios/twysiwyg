package twe.actions.misc;

import javax.swing.text.DefaultEditorKit.*;
import javax.swing.*;
import twe.actions.*;
import javax.swing.text.JTextComponent;
import java.awt.event.ActionEvent;
import twe.util.*;
import javax.swing.text.html.*;
import java.io.*;
import java.net.*;
import org.w3c.tidy.*;
import javax.swing.text.*;
import twe.translator.*;
import twe.gui.*;
import javax.swing.text.html.parser.*;
/**
 *
 * <p>Description: "Open document" action </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class OpenAction
    extends AbstractAction implements TWAction{

// icon for the action
  private Icon icon;

// target editor for the action
  private JTextComponent editor;

// the button for the action
  private JButton button;


  public OpenAction(JTextComponent editor){
    // Retrieve resource from jar
    this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/fileopen.png"));

    this.editor = editor;
    this.button = new JButton(this);
    this.button.setIcon(icon);
    this.button.setText("");
    this.button.setToolTipText("Open document");

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

  public void openURL(URL url){
    ((JEditorPane)editor).setEditorKit(new MyHTMLEditorKit());
    try {
      ( (JEditorPane) editor).setPage(url);
    }
    catch (IOException ex) {
      ex.printStackTrace();
    }
    ((MainFrame)editor).initUndoRedo();
  }

  private static String readFile(String filename) throws IOException {
   String lineSep = System.getProperty("line.separator");
   BufferedReader br = new BufferedReader(new FileReader(filename));
   String nextLine = "";
   StringBuffer sb = new StringBuffer();
   while ((nextLine = br.readLine()) != null) {
     sb.append(nextLine);
     //
     // note:
     //   BufferedReader strips the EOL character.
     //
     sb.append(lineSep);
   }
   return sb.toString();
}



  /**
   * Open a document from a string in TWiki syntax
   * @param data String
   */
  public void openFromTwikiString(String data){
    ((JEditorPane)editor).setEditorKit(new MyHTMLEditorKit());
// ((HTMLDocument)editor.getDocument()).setAsynchronousLoadPriority(-1);
    if (data != null)
      ( (JEditorPane) editor).setText(TwikiToHtml.translate(data));

  ((MainFrame)editor).initUndoRedo();
  ((MainFrame)editor).initDocTree();
  ((MainFrame)editor).configListeners();
  ((MainFrame)editor).initCpl();

  ((MainFrame)editor).updateDocTree();

}

  /**
   * actionPerformed
   *
   * @param e ActionEvent
   */
  public void actionPerformed(ActionEvent e) throws IOException {
    JFileChooser fc = new JFileChooser();
    fc.addChoosableFileFilter(new AllExtensionFilter());

    fc.showOpenDialog(editor);
    if (fc.getSelectedFile() == null) return;

    if (fc.getSelectedFile().getName().endsWith(".html"))
      openURL(fc.getSelectedFile().toURL());
    if (fc.getSelectedFile().getName().endsWith(".twiki")){
      String fileContent = OpenAction.readFile(fc.getSelectedFile().getAbsolutePath());
      openFromTwikiString(TwikiToHtml.translate(fileContent));
    }

    ((MainFrame)editor).initUndoRedo();
    ((MainFrame)editor).updateDocTree();
    /*try {
        BufferedReader in = new BufferedReader(new FileReader(fc.getSelectedFile()));
        String str;
        while ((str = in.readLine()) != null) {
            process(str);
        }
        in.close();
    } catch (IOException e) {
    }
  try {
    ( (HTMLDocument) editor.getDocument()).setBase(fc.getSelectedFile().toURL());
    FileInputStream fis = null;
    try {
      fis = new FileInputStream(fc.getSelectedFile());
    }
    catch (FileNotFoundException ex1) {
      ex1.printStackTrace();
    }

    System.out.println(fc.getSelectedFile().toURL());
    JEditorPane ep = new JEditorPane(fc.getSelectedFile().toURL());
    StringReader r = new StringReader(fc.getSelectedFile().toString());
    ((JEditorPane)editor).setPage(fc.getSelectedFile().toURL());
//    editor.read(new FileReader(fc.getSelectedFile()),editor);
  }
  catch (MalformedURLException ex) {
    ex.printStackTrace();
  }
    editor.setDocument(new HTMLDocument());*/
  }

  private class TWEParser extends ParserDelegator{

  }

  private class MyHTMLEditorKit extends HTMLEditorKit {


    public Document createDefaultDocument() {
  Document doc = super.createDefaultDocument();
  ((HTMLDocument)doc).setAsynchronousLoadPriority(-1);
  ((HTMLDocument)doc).setPreservesUnknownTags(false);

  return doc;
  }
  }



}

