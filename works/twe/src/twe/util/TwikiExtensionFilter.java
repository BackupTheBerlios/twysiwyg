package twe.util;

import java.io.*;

/**
 *
 * <p> </p>
 * <p>Description: The file extension filter for .twiki </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TwikiExtensionFilter
    extends javax.swing.filechooser.FileFilter {

  public boolean accept(File file) {
            String filename = file.getName();
            return filename.endsWith(".twiki");
        }
        public String getDescription() {
            return "TWiki Files (*.twiki)";
        }
    }
