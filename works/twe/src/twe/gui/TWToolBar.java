package twe.gui;

import javax.swing.*;
import twe.actions.*;
import java.util.*;
import java.awt.*;
/**
 *
 * <p> </p>
 * <p>Description: A toolbar with some extra features for TWE</p>
 * <p> </p>
 * <p> </p>
 * @author Damien Mandrioli
 * @version 1.0
 */
public class TWToolBar extends JToolBar{

  FlowLayout layout;

  // A set of actions
  ArrayList actions = new ArrayList();


  public TWToolBar() {
    super();
  }
  public void addAction(TWAction action){
    actions.add(action);
    JButton button = action.getButton();

    this.add(button);

  }

  /**
   *
   * @param ac Class
   * @return first action corresponding to argument in toolbar
   */
  public TWAction getAction(Class ac){
    for (int i = 0; i < actions.size(); i++)
      if (actions.get(i).getClass() == ac)
        return (TWAction)actions.get(i);
    return null;
  }

}
