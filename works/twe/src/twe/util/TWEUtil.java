package twe.util;

import javax.swing.text.*;
import javax.swing.text.html.*;
/**
 *
 * <p> </p>
 * <p>Description: Some static functions on document et elements.</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWEUtil {

  public static String getElementText(Element e, Document doc) {
        try {
          return doc.getText(e.getStartOffset(),
                             e.getEndOffset() - e.getStartOffset());
        }
        catch (BadLocationException ex) {
          return null;
        }
      }

      /**
           * get the index of a given element in the list of its parents elements.
           *
           * @param elem  the element to get the index number for
           * @return the index of the given element
           */
          public static int getElementIndex(Element elem) {
            int i = 0;
            Element parent = elem.getParentElement();
            if (parent != null) {
              int last = parent.getElementCount() - 1;
              Element anElem = parent.getElement(i);
              if (anElem != elem) {
                while ( (i < last) && (anElem != elem)) {
                  anElem = parent.getElement(++i);
                }
              }
            }
            return i;
          }

          public static Element getBodyElement(HTMLDocument doc, Element elem) {
            Element refElem;
            if (elem == null)
              elem = doc.getDefaultRootElement();
            for (int i = 0; i < elem.getElementCount(); i++) {
              refElem = elem.getElement(i);
              AttributeSet attr = refElem.getAttributes();
              Object nameAttribute = attr.getAttribute(StyleConstants.NameAttribute);
              if (nameAttribute == HTML.Tag.BODY) {
                return refElem;
              }
              else {
                getBodyElement(doc, refElem);
              }
            }
            return null;
          }

          public static Element getNextElement(Element e){
            Element parent = e.getParentElement();
            int index = getElementIndex(e);
            if (parent.getElementCount() -1 > index)
              return parent.getElement(index + 1);
            else return null;
          }
}
