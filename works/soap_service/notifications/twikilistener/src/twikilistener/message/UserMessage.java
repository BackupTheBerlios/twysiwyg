package twikilistener.message;

/**
 * User message
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: </p>
 * @author Romain Raugi
 * @version 1.0
 */
public class UserMessage extends Message {

  /**
   * User defined Message
   * @param text String
   */
  public UserMessage(String text) {
    super();
    this.setText(text);
    this.setEvent(null);
    this.setType(0);
  }

}
