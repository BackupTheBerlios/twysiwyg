package events;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import twikilistener.*;
import twikilistener.message.Message;
import javax.swing.border.*;

/**
 * Console
 * <p>Title: Events Console</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: </p>
 * @author Romain Raugi
 * @version 1.0
 */
public class Console extends JDialog implements java.util.Observer {

  private JScrollPane jScrollPane1 = new JScrollPane();
  private TitledBorder titledBorder1;
  private JList log;
  private TitledBorder titledBorder2;
  private GridBagLayout gridBagLayout1 = new GridBagLayout();
  private DefaultListModel model = new DefaultListModel();
  private ImageIcon unlockIcon = new ImageIcon(getClass().getResource("unlock.gif"));
  private ImageIcon lockIcon = new ImageIcon(getClass().getResource("lock.gif"));
  private ImageIcon topiclockIcon = new ImageIcon(getClass().getResource("topiclock.gif"));
  private ImageIcon topicunlockIcon = new ImageIcon(getClass().getResource("topicunlock.gif"));
  private ImageIcon topicIcon = new ImageIcon(getClass().getResource("topic.gif"));
  private ImageIcon refactoringIcon = new ImageIcon(getClass().getResource("refactoring.gif"));
  private ImageIcon deleteIcon = new ImageIcon(getClass().getResource("delete.gif"));
  private ImageIcon trashIcon = new ImageIcon(getClass().getResource("trash.gif"));
  private ImageIcon connectionIcon = new ImageIcon(getClass().getResource("connection.gif"));
  private ImageIcon disconnectionIcon = new ImageIcon(getClass().getResource("disconnection.gif"));
  private ImageIcon linkIcon = new ImageIcon(getClass().getResource("link.gif"));
  private ImageIcon globalIcon = new ImageIcon(getClass().getResource("global.gif"));

  private Color refactoringBgColor = new Color(150, 200, 150);
  private Color refactoringFgColor = new Color(0, 100, 0);
  private Color topicBgColor = new Color(200, 200, 255);
  private Color topicFgColor = new Color(0, 0, 100);
  private Color connectionBgColor = new Color(250, 250, 200);
  private Color connectionFgColor = new Color(100, 100, 0);
  private Color removeBgColor = new Color(255, 150, 150);
  private Color removeFgColor = new Color(100, 0, 0);
  private Color trashBgColor = new Color(255, 200, 200);
  private Color trashFgColor = new Color(100, 0, 0);
  private Color globalBgColor = new Color(220, 220, 220);
  private Color globalFgColor = new Color(100, 100, 100);
  private Color lockBgColor = new Color(150, 200, 200);
  private Color lockFgColor = new Color(0, 100, 100);

  /**
   * Construct the frame
   * @throws Exception
   */
  public Console() throws Exception {
    // UI
    enableEvents(AWTEvent.WINDOW_EVENT_MASK);
    log = new JList(model);
    log.setCellRenderer(new Cell());
    this.initUI();
  }

  /**
   * Notification
   * @param o Observable
   * @param arg Object
   */
  public void update(java.util.Observable o, Object arg) {
    Message message = (Message)arg;
    // Add message to list
    model.add(0, message);
  }

  /**
   * Overridden so we can exit when window is closed
   * @param e WindowEvent
   */
  protected void processWindowEvent(WindowEvent e) {
    super.processWindowEvent(e);
    if (e.getID() == WindowEvent.WINDOW_CLOSING) {
      System.exit(0);
    }
  }

  private void initUI() throws Exception {
    titledBorder1 = new TitledBorder("");
    titledBorder2 = new TitledBorder("");
    this.getContentPane().setLayout(gridBagLayout1);
    jScrollPane1.getViewport().setBackground(Color.lightGray);
    jScrollPane1.setBorder(titledBorder2);
    log.setToolTipText("");
    this.getContentPane().add(jScrollPane1,  new GridBagConstraints(0, 0, 1, 1, 1.0, 1.0
            ,GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(8, 8, 9, 10), 365, 251));
    jScrollPane1.getViewport().add(log, null);
    this.setSize(300, 200);
    this.setTitle("Events Console");
  }

  class Cell extends JLabel implements ListCellRenderer {

    public Component getListCellRendererComponent(JList list,
                                                  Object value,
                                                  int index,
                                                  boolean isSelected,
                                                  boolean cellHasValue) {
      Message message = (Message)value;
      this.setOpaque(true);
      // Display message with the appropriate style
      try {
        switch(message.getType()) {
          case 0:
            this.setIcon(globalIcon);
            this.setBackground(globalBgColor);
            this.setForeground(globalFgColor);
            break;
          case 1:
            if (message.getEvent().getConnectionEvent().getConnected())
              this.setIcon(connectionIcon);
            else
              this.setIcon(disconnectionIcon);
            this.setBackground(connectionBgColor);
            this.setForeground(connectionFgColor);
            break;
          case 2:
            if (message.getEvent().getLockEvent().getLocked())
              this.setIcon(lockIcon);
            else
              this.setIcon(unlockIcon);
            this.setBackground(lockBgColor);
            this.setForeground(lockFgColor);
            break;
          case 3:
            if (message.getEvent().getRefactoringEvent().getOperation().equals("remove")) {
              if (message.getEvent().getRefactoringEvent().getNewWeb().equals("")) {
                this.setIcon(deleteIcon);
                this.setBackground(removeBgColor);
                this.setForeground(removeFgColor);
              }
              else {
                this.setIcon(trashIcon);
                this.setBackground(trashBgColor);
                this.setForeground(trashFgColor);
              }
            }
            else {
              this.setIcon(refactoringIcon);
              this.setBackground(refactoringBgColor);
              this.setForeground(refactoringFgColor);
            }
            break;
          case 4:
            if (message.getEvent().getTopicEvent().getOperation().equals("lock"))
              this.setIcon(topiclockIcon);
            else if (message.getEvent().getTopicEvent().getOperation().equals("unlock"))
              this.setIcon(topicunlockIcon);
            else if (message.getEvent().getTopicEvent().getOperation().equals("links"))
              this.setIcon(linkIcon);
            else
              this.setIcon(topicIcon);
            this.setBackground(topicBgColor);
            this.setForeground(topicFgColor);
            break;
        }

      }
      catch(Exception e) {
        // Default parameters
        this.setIcon(globalIcon);
        this.setBackground(globalBgColor);
        this.setForeground(globalFgColor);
      }
      this.setBorder(new TitledBorder(""));
      this.setText(message.getText());
      return this;
    }
  }

  public static void main(String[] args) throws Exception {
    int port = Integer.parseInt(args[0]);
    // Initialialize listener
    TWikiListener listener = new TWikiListener(port);
    // Create console
    Console console = new Console();
    console.show();
    // Add console as listener
    listener.addObserver(console);
    // Close socket (never reached here)
    //listener.close();
  }

}
