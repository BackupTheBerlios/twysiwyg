package twe.gui;
/*
 * Usable for futur developments.
 * TableDemo.java
 *
 */

import java.util.*;
import javax.swing.*;
import javax.swing.table.*;
import javax.swing.event.*;
/**
 *
 */
public class TableDemo extends javax.swing.JFrame {

    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JTable theTable;

    /** Creates new form TableDemo */
    public TableDemo() {
        initComponents();
        initTable();
    }

    private void initTable() {
           theTable.setModel(new MyOwnTableModel());
           theTable.setCellSelectionEnabled(true);
           theTable.setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
           ListSelectionModel rowSM = theTable.getSelectionModel();
           rowSM.addListSelectionListener(new ListSelectionListener() {
                   public void valueChanged(ListSelectionEvent e) {
                       //Ignore extra messages.
                       if (e.getValueIsAdjusting()) return;
                       ListSelectionModel lsm = (ListSelectionModel)e.getSource();
                       if (lsm.isSelectionEmpty()) {
                           System.out.println("No rows are selected.");
                       } else {
                           int selectedRowFrom = lsm.getMinSelectionIndex();
                           int selectedRowTo = lsm.getMaxSelectionIndex();
                           if (selectedRowTo==selectedRowFrom)
                               System.out.println("Row " + selectedRowFrom
                                              + " is now selected.");
                           else
                               System.out.println("Rows " + selectedRowFrom
                                                  + " to " + selectedRowTo + " are now selected.");
                       }
                   }
               });
           ListSelectionModel colSM = theTable.getColumnModel().getSelectionModel();
           colSM.addListSelectionListener(new ListSelectionListener() {
                   public void valueChanged(ListSelectionEvent e) {
                       //Ignore extra messages.
                       if (e.getValueIsAdjusting()) return;

                       ListSelectionModel lsm = (ListSelectionModel)e.getSource();
                       if (lsm.isSelectionEmpty()) {
                           System.out.println("No columns are selected.");
                       } else {
                           int selectedColFrom = lsm.getMinSelectionIndex();
                           int selectedColTo = lsm.getMaxSelectionIndex();
                           if (selectedColFrom==selectedColTo)
                               System.out.println("Column " + selectedColFrom
                                                  + " is now selected.");
                           else
                               System.out.println("Columns " + selectedColFrom
                                                  + " to " + selectedColTo + " are now selected.");
                       }
                   }
           });
       }


    private void initComponents() {
        jScrollPane1 = new javax.swing.JScrollPane();
        theTable = new javax.swing.JTable();

        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent evt) {
                exitForm(evt);
            }
        });

        jScrollPane1.setViewportView(theTable);

        getContentPane().add(jScrollPane1, java.awt.BorderLayout.CENTER);

        pack();
    }

    /** Exit the Application */
    private void exitForm(java.awt.event.WindowEvent evt) {
        System.exit(0);
    }

    public static void main(String args[]) {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        }
        catch (Exception e) {
            System.exit(0);
        }

        new TableDemo().show();
    }

    public class MyOwnTableModel extends DefaultTableModel {

        final String[] columnNames = { "Day",
                                       "08:00-08:15", "08:15-08:30",
                                       "08:30-08:45", "08:45-09:00" };

        private Object data[][] = {
                {"Monday", " ", " ", " ", " "},
                {"Tuesday", " ", " ", " ", " "},
                {"Wednesday", " ", " ", " ", " "},
                {"Thursday", " ", " ", " ", " "},
                {"Friday", " ", " ", " ", " "},
                {"Saturday", " ", " ", " ", " "},
                {"Sunday", " ", " ", " ", " "},
        };

        public MyOwnTableModel() {
        }
        public boolean isCellEditable(int row, int col) { return false; }
        public Class getColumnClass(int col) {
            return super.getColumnClass(col);
        }
        public int getRowCount() { return 7; }
        public int getColumnCount() { return 5; }
        public String getColumnName(int col) {
            return columnNames[col];
        }
        public Object getValueAt(int row, int col) {
            return data[row][col];
        }
     }
}
