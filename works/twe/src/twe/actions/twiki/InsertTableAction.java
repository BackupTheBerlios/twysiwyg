package twe.actions.twiki;

import javax.swing.*;
import java.awt.event.*;
import javax.swing.text.html.*;
import java.io.*;
import javax.swing.text.*;
import twe.actions.*;
import java.awt.*;

import java.beans.*;
import javax.swing.event.*;
import javax.swing.table.*;
import java.util.*;
import javax.swing.border.*;
import twe.gui.*;
import twe.util.*;

public class InsertTableAction
    extends AbstractAction
    implements TWAction {

  private JTextComponent editorPane;
  private Icon icon;
  private JButton button;
  private JDialog dial;
  private boolean cancelled = true;
  private JSpinner spinW ;
  private JSpinner spinH;
  public InsertTableAction(JTextComponent editor) {
    super("insert-table");
    this.editorPane = editor;
    // Retrieve resource from jar
    //       this.icon = new ImageIcon(this.getClass().getClassLoader().getResource("twe/rsc/newtodo.png"));

    this.button = new JButton(this);
    //     this.button.setIcon(icon);

    initSpin();
  }

private void initSpin(){
  SpinnerNumberModel spW = new SpinnerNumberModel(4, 1, 25, 1);
    SpinnerNumberModel spH = new SpinnerNumberModel(3, 1, 25, 1);

    spinW = new JSpinner(spW);
    spinH = new JSpinner(spH);
}


  JTable table = new JTable(3, 4);

  public void actionPerformed(ActionEvent ae) {

    HTMLDocument doc = (HTMLDocument) editorPane.getDocument();
    JPanel popPanel = new JPanel();

    SpringLayout sl = new SpringLayout();
    popPanel.setLayout(sl);
    String W = SpringLayout.WEST;
    String E = SpringLayout.EAST;
    String N = SpringLayout.NORTH;
    String S = SpringLayout.SOUTH;
    sl.putConstraint(W, spinW, 165, W, popPanel);
    sl.putConstraint(N, spinW, 5, N, popPanel);

    // Action for update table sample column spiner change
    spinW.addChangeListener(new ChangeListener() {
      public void stateChanged(ChangeEvent e) {
        JSpinner spin = (JSpinner) e.getSource();
        DefaultTableModel model = ( (DefaultTableModel) table.getModel());
        if (model.getColumnCount() < ( (Integer) spin.getValue()).intValue()) {
          for (int i = model.getColumnCount();
               i < ( (Integer) spin.getValue()).intValue(); i++) {
            model.addColumn(new Vector());
          }
        }
        else {
          model.setColumnCount( ( (Integer) spin.getValue()).intValue());

        }
      }
    });
    // Action for update table sample row spiner change
    spinH.addChangeListener(new ChangeListener() {
      public void stateChanged(ChangeEvent e) {
        JSpinner spin = (JSpinner) e.getSource();
        DefaultTableModel model = ( (DefaultTableModel) table.getModel());
        for (int i = 0;
             i <=
             Math.abs(model.getColumnCount() - ( (Integer) spin.getValue()).intValue());
             i++) {
          if (model.getRowCount() < ( (Integer) spin.getValue()).intValue()) {
            model.addRow(new Vector());
          }
          else if (model.getRowCount() > ( (Integer) spin.getValue()).intValue()) {
            model.removeRow(0);
          }
        }
      }
    });

    sl.putConstraint(W, spinH, 3, W, popPanel);
    sl.putConstraint(N, spinH, 110, N, popPanel);

    Dimension dim = new Dimension(265, 160);
    table.setMinimumSize(dim);
    table.setMaximumSize(dim);
    table.setSize(dim);
    table.setPreferredSize(dim);
    table.setBorder(new LineBorder(Color.BLACK, 1, true));
    sl.putConstraint(W, table, 15, E, spinH);
    sl.putConstraint(N, table, 15, S, spinW);

    popPanel.add(spinW);
    popPanel.add(spinH);
    popPanel.add(table);
    JFrame frame = new JFrame("Insert table");
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    int w = 350;
    int h = 290;
    int x = (int) (screenSize.getWidth() - w) / 2;
    int y = (int) (screenSize.getHeight() - h) / 2;
    frame.setUndecorated(false);

    dial = new JDialog( ( (MainFrame) editorPane).getMainFrame(),
                       "Insert table", true);
    JFrame.setDefaultLookAndFeelDecorated(false);

    JButton cancel = new JButton("Cancel");
    JButton insert = new JButton("Insert table");

    cancel.addActionListener(new ActionListener() {
      /**
       * actionPerformed
       *
       * @param e ActionEvent
       */
      public void actionPerformed(ActionEvent e) {
        dial.setVisible(false);
        spinW.setValue(new Integer(3));
        spinH.setValue(new Integer(4));
        cancelled = true;
      }
    });
    insert.addActionListener(new ActionListener() {
      /**
       * actionPerformed
       *
       * @param e ActionEvent
       */
      public void actionPerformed(ActionEvent e) {
        dial.setVisible(false);
        cancelled = false;
      }
    });

    JPanel butPane = new JPanel(new FlowLayout(FlowLayout.RIGHT));
    butPane.add(cancel);
    butPane.add(insert);

    dial.getContentPane().add(new JLabel("Adjust table size."),
                              BorderLayout.NORTH);
    dial.getContentPane().add(popPanel, BorderLayout.CENTER);
    dial.getContentPane().add(butPane, BorderLayout.SOUTH);

    dial.setBounds(x, y, w, h);
    dial.setResizable(false);
    dial.setVisible(true);
    StringBuffer sb = new StringBuffer();

    if (!cancelled) {
      cancelled = true;
      sb.append("<table border=\"1\" cellspacing=\"0\" width=\"");
      sb.append(editorPane.getWidth() * 0.75);
      sb.append("\">");

      for (int i = 0; i < ( (Integer) spinH.getValue()).intValue(); i++) {
        sb.append("<tr>");
        for (int j = 0; j < ( (Integer) spinW.getValue()).intValue(); j++) {
          sb.append("<td></td>");
        }
        sb.append("</tr>");
      }
      sb.append("</table>");

      Element elem = doc.getParagraphElement(editorPane.getCaretPosition());

      try {
        Element pt = doc.getCharacterElement(editorPane.getCaretPosition());

        doc.insertAfterEnd(pt, sb.toString());

        int pos = pt.getParentElement().getStartOffset();
        editorPane.setCaretPosition(pos);
}
      catch (Exception ex) {
        ex.printStackTrace();
      }

    }
    editorPane.requestFocus();
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

}
