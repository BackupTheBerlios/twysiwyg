package twikilistener;

import java.net.ServerSocket;
import java.net.Socket;
import java.io.*;
import twikilistener.message.Message;

/**
 * TWiki Messages Listener
 * <p>Title: TWiki Messages Listener</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: </p>
 * @author Romain Raugi
 * @version 1.0
 */
public class TWikiListener
    extends java.util.Observable implements Runnable {

  /** Server Socket */
  private ServerSocket socket;
  /** Port */
  private int port;
  /** Thread */
  private Thread listener;

  /**
   * Build a TWiki messages listener
   * @param port int
   * @throws Exception
   */
  public TWikiListener(int port) throws Exception {
    // Port
    this.port = port;
    // Create server socket
    this.socket = new ServerSocket(port);
    // Create thread
    listener = new Thread(this);
    listener.start();
  }

  /**
   * Close interceptor
   * @throws IOException
   */
  public void close() throws IOException {
    // Close socket
    this.socket.close();
  }

  /**
   * Read client's message
   * @throws Exception
   * @return Message
   */
  private synchronized Message readMessage() throws Exception {
    Socket clientSocket = socket.accept();
    // Read message
    InputStream istream = clientSocket.getInputStream();
    InputStreamReader sreader = new InputStreamReader(istream);
    BufferedReader buffer = new BufferedReader(sreader);
    // StringWriter
    StringWriter writer = new StringWriter();
    String str = "";
    while (str != null) {
      // Read message
      str = buffer.readLine();

      if (str != null) writer.write(str);
    }
    buffer.close();
    clientSocket.close();
    // Whole message
    StringReader reader = new StringReader(writer.toString());
    Message message = (Message)Message.unmarshal(reader);
    return message;
  }

  /**
   * Thread
   */
  public void run() {
    // Only one client : TWiki
    while( true ) {
      try {
        // Read client's message
        Message message = readMessage();
        // Notify change
        this.setChanged();
        this.notifyObservers(message);
      }
      catch (Exception e) {
        // Dispatch exception
        this.notifyObservers(e);
      }
    }
  }
}
