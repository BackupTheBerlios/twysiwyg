package twe.util;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.ResourceBundle;
import java.util.Locale;
import javax.swing.event.*;

/**
 *
 * <p> </p>
 * <p>Description: The configuration dialog inspired from PasswordDialog.</p>
 * <p> </p>
 * <p> </p>
 * @author Ostermills
 * @version 1.0
 */

public class ConfigurationDialog
    extends JDialog {

    /**
     * Locale specific strings displayed to the user.
     *
     * @since ostermillerutils 1.00.00
     */
    protected ResourceBundle labels;

    public boolean getRemember() {
      return rememberCB.isSelected() ;
    }

  public void setRemember(boolean remember) {
    rememberCB.setSelected(remember);

  }



  /**
     * Set the locale used for getting localized
     * strings.
     *
     * @param locale Locale used to for i18n.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setLocale(Locale locale){
//        labels = ResourceBundle.getBundle("com.Ostermiller.util.PasswordDialog",  locale);
    }

    /**
     * Where the name is typed.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JTextField name;
    /**
     * Where the password is typed.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JPasswordField pass;


    private JCheckBox rememberCB;
    /**
     * The OK button.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JButton okButton;
    /**
     * The cancel button.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JButton cancelButton;
    /**
     * The label for the field in which the name is typed.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JLabel nameLabel;
    /**
     * The label for the field in which the password is typed.
     *
     * @since ostermillerutils 1.00.00
     */
    protected JLabel passLabel;

    /**
     * Set the name that appears as the default
     * An empty string will be used if this in not specified
     * before the dialog is displayed.
     *
     * @param name default name to be displayed.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setName(String name){
        this.name.setText(name);
    }

    /**
     * Set the password that appears as the default
     * An empty string will be used if this in not specified
     * before the dialog is displayed.
     *
     * @param pass default password to be displayed.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setPass(String pass){
        this.pass.setText(pass);
    }

    /**
     * Set the label on the OK button.
     * The default is a localized string.
     *
     * @param ok label for the ok button.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setOKText(String ok){
        this.okButton.setText(ok);
        pack();
    }

    /**
     * Set the label on the cancel button.
     * The default is a localized string.
     *
     * @param cancel label for the cancel button.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setCancelText(String cancel){
        this.cancelButton.setText(cancel);
        pack();
    }

    /**
     * Set the label for the field in which the name is entered.
     * The default is a localized string.
     *
     * @param name label for the name field.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setNameLabel(String name){
        this.nameLabel.setText(name);
        pack();
    }

    /**
     * Set the label for the field in which the password is entered.
     * The default is a localized string.
     *
     * @param pass label for the password field.
     *
     * @since ostermillerutils 1.00.00
     */
    public void setPassLabel(String pass){
        this.passLabel.setText(pass);
        pack();
    }

    /**
     * Get the name that was entered into the dialog before
     * the dialog was closed.
     *
     * @return the name from the name field.
     *
     * @since ostermillerutils 1.00.00
     */
    public String getName(){
        return name.getText();
    }

    /**
     * Get the password that was entered into the dialog before
     * the dialog was closed.
     *
     * @return the password from the password field.
     *
     * @since ostermillerutils 1.00.00
     */
    public String getPass(){
        return new String(pass.getPassword());
    }

    /**
     * Finds out if user used the OK button or an equivalent action
     * to close the dialog.
     * Pressing enter in the password field may be the same as
     * 'OK' but closing the dialog and pressing the cancel button
     * are not.
     *
     * @return true if the the user hit OK, false if the user canceled.
     *
     * @since ostermillerutils 1.00.00
     */
    public boolean okPressed(){
        return pressed_OK;
    }

    /**
     * update this variable when the user makes an action
     *
     * @since ostermillerutils 1.00.00
     */
    private boolean pressed_OK = false;

    /**
     * Create this dialog with the given parent and title.
     *
     * @param parent window from which this dialog is launched
     * @param title the title for the dialog box window
     *
     * @since ostermillerutils 1.00.00
     */
  public ConfigurationDialog(Frame parent, String title) {

        super(parent, title, true);

        setLocale(Locale.getDefault());

        if (title==null){
            setTitle("Authentification");
        }
        if (parent != null){
            setLocationRelativeTo(parent);
        }
        // super calls dialogInit, so we don't need to do it again.
    }

    /**
     * Create this dialog with the given parent and the default title.
     *
     * @param parent window from which this dialog is launched
     *
     * @since ostermillerutils 1.00.00
     */
  public ConfigurationDialog(Frame parent) {
        this(parent, null);
    }

    /**
     * Create this dialog with the default title.
     *
     * @since ostermillerutils 1.00.00
   */
  public ConfigurationDialog() {
        this(null, null);
    }

    /**
     * Called by constructors to initialize the dialog.
     *
     * @since ostermillerutils 1.00.00
     */
    protected void dialogInit(){

        if (labels == null){
            setLocale(Locale.getDefault());
        }

        name = new JTextField("", 20);
        pass = new JPasswordField("", 20);
        okButton = new JButton("OK");
        cancelButton = new JButton("Cancel");
        nameLabel = new JLabel("WikiName ");
        passLabel = new JLabel("Password ");

        super.dialogInit();

        KeyListener keyListener = (new KeyAdapter() {
            public void keyPressed(KeyEvent e){
                if (e.getKeyCode() == KeyEvent.VK_ESCAPE ||
                        (e.getSource() == cancelButton
                        && e.getKeyCode() == KeyEvent.VK_ENTER)){
                    pressed_OK = false;
                    ConfigurationDialog.this.hide();
                }
                if (e.getSource() == okButton &&
                        e.getKeyCode() == KeyEvent.VK_ENTER){
                    pressed_OK = true;
                    ConfigurationDialog.this.hide();
                }
            }
        });
        addKeyListener(keyListener);

        ActionListener actionListener = new ActionListener() {
            public void actionPerformed(ActionEvent e){
                Object source = e.getSource();
                if (source == name){
                    // the user pressed enter in the name field.
                    name.transferFocus();
                } else {
                    // other actions close the dialog.
                    pressed_OK = (source == pass || source == okButton);
                    ConfigurationDialog.this.hide();
                }
            }
        };

        GridBagLayout gridbag = new GridBagLayout();
        GridBagConstraints c = new GridBagConstraints();
        c.gridy = 1;
        c.insets.top = 5;
        c.insets.bottom = 5;
        JPanel pane = new JPanel(gridbag);
        pane.setBorder(BorderFactory.createEmptyBorder(10, 20, 5, 20));
        JLabel label;

        c.anchor = GridBagConstraints.EAST;
        gridbag.setConstraints(nameLabel, c);
        pane.add(nameLabel);

        gridbag.setConstraints(name, c);
        name.addActionListener(actionListener);
        name.addKeyListener(keyListener);
        pane.add(name);

        c.gridy = 2;
        gridbag.setConstraints(passLabel, c);
        pane.add(passLabel);

        gridbag.setConstraints(pass, c);
        pass.addActionListener(actionListener);
        pass.addKeyListener(keyListener);
        pane.add(pass);

        c.gridy = 0;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.anchor = GridBagConstraints.WEST;
        rememberCB = new JCheckBox("Remember login and password ?");
        rememberCB.addChangeListener(new ChangeListener(){

      public void stateChanged(ChangeEvent e) {
        if (rememberCB.isSelected()){
          name.setEnabled(true);
          pass.setEnabled(true);
        }
        else{
          name.setEnabled(false);
          pass.setEnabled(false);


        }
      }
    });
        gridbag.setConstraints(rememberCB, c);
        setRemember(true);
        pane.add(rememberCB);


        c.gridy = 3;
        c.gridwidth = GridBagConstraints.REMAINDER;
        c.anchor = GridBagConstraints.EAST;
        JPanel panel = new JPanel();
        okButton.addActionListener(actionListener);
        okButton.addKeyListener(keyListener);
        panel.add(okButton);
        cancelButton.addActionListener(actionListener);
        cancelButton.addKeyListener(keyListener);
        panel.add(cancelButton);
        gridbag.setConstraints(panel, c);
                pane.add(panel);


        getContentPane().add(pane);

        pack();
    }

    /**
     * Shows the dialog and returns true if the user pressed ok.
     *
     * @return true if the the user hit OK, false if the user canceled.
     *
     * @since ostermillerutils 1.00.00
     */
    public boolean showDialog(){
        show();
        return okPressed();
    }
    public boolean showDialog(boolean rem){
      setRemember(rem);
      show();
      return okPressed();
    }

    /**
     * A simple example to show how this might be used.
     * If there are arguments passed to this program, the first
     * is treated as the default name, the second as the default password
     *
     * @param args command line arguments: name and password (optional)
     *
     * @since ostermillerutils 1.00.00
     */
    private static void main(String[] args){
        ConfigurationDialog p = new ConfigurationDialog();
        if(args.length > 0){
            p.setName(args[0]);
        }
        if(args.length > 1){
            p.setPass(args[1]);
        }
        if(p.showDialog()){
            System.out.println("Name: " + p.getName());
            System.out.println("Pass: " + p.getPass());
        } else {
            System.out.println("User selected cancel");
        }
        p.dispose();
        p = null;
        System.exit(0);
    }
}
