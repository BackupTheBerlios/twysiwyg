package twe.util;

import javax.xml.rpc.*;
import fr.unice.twikiservice.*;
import java.rmi.*;
import javax.swing.*;
import twe.gui.*;
import java.net.*;
import java.util.prefs.*;
/**
 *
 * <p> </p>
 * <p>Description: represents a connection to the Web service </p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class WSConnection {
  ConnectionInfo cinfo;
  ServicePortType stub;
  Topic topic;

  String topicPath; // Should be 'Web.Topic' format

  String userName;

  boolean offline = false;

  MainFrame control;

  /**
   * Set the reference of topic, remove blanks before or after if any
   * @param s the topic reference
   */
  public void setTopicPath(String s){
    topicPath = s.trim();
  }

  public WSConnection(MainFrame control) {
    this.control = control;
    initConnection();

  }

  /**
   *
   * @return the connection key of -inf if not connected
   */
  public int getKey(){
    if (offline)
      return Integer.MIN_VALUE;
    return cinfo.getKey();
  }

private String translate(String s){
  String ret = "../data/";
  s = s.trim();
  if (s.endsWith("/"))
    s = s.substring(0,s.length()-1);
  ret += s.replace('.','/');
  ret += ".txt";
  return ret;
}

/**
 * Update the topic on remote server with content
 * @param content String
 */
public void setTopicContent(String content){
  if (offline)
    return;
  if (topicPath == null)
    System.err.println("null topic path error");

  //topic.setName(topicPath);
 // System.out.println(topic.getWeb() + " " + topic.getName());
  topic.setWeb(topic.getWeb().replaceAll("../data/",""));
  topic.setData(content);
  try {
    // Set the pop up message
    int res = stub.setTopic(getKey(), topic, false,false,false);
    String msg;
    switch (res){
      case 0: msg = "Topic saved on TWiki server."; break;
      case 1: msg = "You must be connected to save topic on server.";break;
      case 2: msg = "The topic does not exist."; break;
      case 4: msg = "You have no permissions to save this topic on server."; break;
      case 5: msg = "Topic is locked by someone else"; break;
      default: msg = "Error n° " + res; break;
    }
    JOptionPane.showMessageDialog(control.getMainFrame(),msg);
  //  logout();
  }
  catch (RemoteException ex) {
    ex.printStackTrace();
  }


}

/**
 * Establish connection with remote server
 */
public void initConnection(){
  try {

    fr.unice.twikiservice.Service service = new ServiceLocator(control.getEndPoint());
    stub = service.getServicePortType();
    if (stub == null)
      System.err.println("Connection error");
  }
  catch (ServiceException ex) {
    offline = true;
    ex.printStackTrace();
  }
}
/**
 * Return the topic referenced by the MainFrame controler
 * @return String
 */
public String getTopicContent(){
  if (offline)
    return null;
  try
     {
       //topic = stub.getTopic(translate(topicAdr));
       String param = control.getWebTopic().replace('.','/').trim() + ".txt";
       //System.out.println(param + " " +getKey());
       try{
       topic = stub.getTopic(param,getKey());
       }
       catch (Exception e){
         JOptionPane.showMessageDialog(control.getMainFrame(),"Topic is locked.");
         logout();
         control.requestFocus();
         return "";
       }
       if (topic.getData() == null)
         return "";
       return topic.getData();

     }
     catch(Exception e)
     {

       e.printStackTrace();
     }
     return null;
}
   /**
    *
    * @return status of connection for show in the bottom of frame
    */
   public String getStatus(){
     if (offline)
       return "Disconnected.";
     String dest = "TWiki WYSIWYG Editor";
     try{
     dest = "Login as : " + userName + " - " +
         "Session Key : " + cinfo.getKey() + " - " +
         "Lock time : " + cinfo.getTimeout() + " seconds - " +
         "Topic : " + topicPath;

   }
     catch (NullPointerException e){
       e.printStackTrace();
     }

     return dest;
   }
   /**
    * Explicit disconnection with the server
    */
   public void logout(){
    if (offline)
      return;
     try {
      if (cinfo == null)
        return;
      if (stub.disconnect(cinfo.getKey()))
        control.setLog("Disconnected.");
        else control.setLog("Already disconnected.");
    }
    catch (RemoteException ex) {
      ex.printStackTrace();
    }
   }

   /**
    *
    * @return all topics of server with format 'Web.Topic'
    */
   public String [] getTree(){

     if (topic == null || offline) return null;

     String can = topic.getName();
     String[] t = null;
     try {

     t = stub.getAllTopic(getKey());

    }
    catch (Exception ex) {
      ex.printStackTrace();
    }
    return t;
   }

   /**
    * Connection to TWiki server
    * @param name login name
    * @param pass password
    */
   public void login(String name,String pass){
    if (offline)
      return;
    Preferences prefs = control.getPrefs();
    // Check system for preferences
    if (prefs.getBoolean("AUTO_LOGIN",false)){
      name = prefs.get("WIKI_NAME",null);
      pass = prefs.get("WIKI_PASS",null);


    }
    // If no preferences and null arguments, popup a dialog
    if (name == null || pass == null){
      PasswordDialog p = new PasswordDialog(control.getMainFrame());
      if( p.showDialog(prefs.getBoolean("AUTO_LOGIN",false))){
        name = p.getName();
        pass = p.getPass();
        // If want to remember password, set system preferences
        if (p.getRemember()){
          prefs.putBoolean("AUTO_LOGIN",true);
          prefs.put("WIKI_NAME",name);
          prefs.put("WIKI_PASS",pass);
        }
        else{
          // for security : remove if any
          prefs.remove("WIKI_NAME");
          prefs.remove("WIKI_PASS");
          prefs.putBoolean("AUTO_LOGIN",false);
        }
      }
      else {
        // If cancel typed
        name = "guest";
        pass = "";
        }
    }
    try {
      cinfo = stub.connect("Edit topic", name, pass);

      if (cinfo == null){
        control.setLog("Login failed.");
        prefs.putBoolean("AUTO_LOGIN",false);
        login(null,null);
        return;
      }
      userName = name;
      control.setLog(getStatus());
    }
        catch (RemoteException ex) {
          ex.printStackTrace();
        }
      }
}
