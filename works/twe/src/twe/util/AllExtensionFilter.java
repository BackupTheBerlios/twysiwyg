package twe.util;

import java.io.*;

/**
 *
 * <p> </p>
 * <p>Description: The file extension filter for .twiki & .html</p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class AllExtensionFilter extends javax.swing.filechooser.FileFilter {

  public boolean accept(File file) {
            String filename = file.getName();
            return filename.endsWith(".html") || filename.endsWith(".twiki");
        }
        public String getDescription() {
            return "TWiki & HTML Files (*.twiki, *.html)";
        }
    }
