package twe.util;

import java.io.*;
import java.util.*;
import javax.swing.tree.*;

/**
 * <p>Title: WikiManagerPrototype</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: </p>
 * @author Romain Raugi
 * @version 1.0
 */
public class Tree implements TreeNode, Serializable {

  /** Linked topic */
  public ComplTopic root;
  /** Parent */
  private Tree parent;
  /** List of children */
  private ArrayList children = new ArrayList();
  /** Hierarchy */
  private int hierarchy = 0;

  /**
   * Build a tree node
   * @param root Topic
   * @param parent Tree
   */
  public Tree(ComplTopic root, Tree parent) {
    this.root = root;
    this.parent = parent;
  }

  /**
   * Absolute position
   * @return String
   */
  public String pwd() {
    return (this.parent != null)? parent.pwd() + "." + root.toString(): root.toString();
  }

  /**
   * Node is leaf ?
   * @return boolean
   */
  public boolean isLeaf() {
    return children.isEmpty();
  }

  public int getChildCount() {
    return children.size();
  }

  public boolean getAllowsChildren() {
    return true;
  }

  public Enumeration children() {
    return new TEnumerator(this.Iterator());
  }

  public TreeNode getParent() {
    return this.parent;
  }

  public TreeNode getChildAt(int i) {
    if (i >= 0 && i < children.size())
      return (TreeNode)children.get(i);
    return null;
  }

  public int getIndex(TreeNode node) {
    if (children.contains(node)) {
      return children.indexOf(node);
    }
    return -1;
  }

  public int getHierarchy() {
    if (this.getParent() != null)
      return ((Tree)this.getParent()).getHierarchy() + 1;
    return 0;
  }

  /**
   * Add a tree as child
   * @param node Tree
   */
  public void addChild(Tree node) {
    children.add(node);
  }

  /**
   * Remove a node
   * @param node Tree
   */
  public void removeChild(Tree node) {
    children.remove(node);
  }

  /**
   * Iterator on children
   * @return Iterator
   */
  public Iterator Iterator() {
    return children.iterator();
  }

  /**
   * Get a node from a name (recursive)
   * @param name String
   * @return Tree
   */
  public Tree getNode(String name) {
    int idx = 0;
    // "." is a separator parent/child
    // No ".", looking directly on children
    if ((idx = name.indexOf(".")) == -1) {
      // Iterate on children to find topic
      Iterator it = this.Iterator();
      Tree node = null;
      while(it.hasNext() && (node == null || ! node.root.getName().equals(name))) {
        node = (Tree)it.next();
      }
      if (node == null) return node;
      if (node.root.getName().equals(name)) return node;
    }
    else {
      // Retrieve root
      Tree tr = getNode(name.substring(0, idx));
      // Looking on next topic
      String next = name.substring(idx + 1);
      if (tr != null)
        return tr.getNode(next);
    }
    // No topic found
    return null;
  }

  /**
   * Return topic
   * @return Topic
   */
  public ComplTopic getTopic() {
    return root;
  }

  /**
   * String representation
   * @return String
   */
  public String toString() {
    return root.toString();
  }

  class TEnumerator implements Enumeration {

    Iterator it;

    public TEnumerator(Iterator it) {
      this.it = it;
    }

    public boolean hasMoreElements() {
      return it.hasNext();
    }

    public Object nextElement() {
      return it.next();
    }
  }

}
