package twe.util;

import java.io.*;

/**
 * <p>Title: Completion system for TWiki topics</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: </p>
 * @author Romain Raugi
 * @version 1.0
 */

public class ComplTopic
    implements Serializable {

  /** Name */
  private String name;
  /** Kind of item */
  private String type;
  /** Location */
  private String location;
  /** Parent */
  private String parent;

  /**
   * ComplTopic instanciation
   * @param name String
   * @param type String
   * @param location String
   * @param parent String
   */
  public ComplTopic(String name, String type, String location, String parent) {
    this.name = name;
    this.type = type;
    this.location = location;
    this.parent = parent;
  }

  /**
   * String representation
   * @return String
   */
  public String toString() {
    return this.name;
  }

  /**
   * Return type
   * @return char
   */
  public String getType() {
    return this.type;
  }

  /**
   * Return name
   * @return String
   */
  public String getName() {
    return this.name;
  }

  /**
   * Return location
   * @return String
   */
  public String getLocation() {
    return this.location;
  }

  /**
   * Return parent
   * @return String
   */
  public String getParent() {
    return this.parent;
  }

  /**
   * Overrides equals method
   * @param o Object
   * @return boolean
   */
  public boolean equals(Object o) {
    if (o instanceof ComplTopic) {
      ComplTopic t = (ComplTopic)o;
      return (t.getName().equals(name) && t.getLocation().equals(location) &&
              t.getType().equals(type) && t.getParent().equals(parent));
    }
    return false;
  }


}
