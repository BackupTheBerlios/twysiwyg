/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: RefactoringEvent.java,v 1.1 2004/09/06 10:29:39 romano Exp $
 */

package twikilistener.message;

  //---------------------------------/
 //- Imported classes and packages -/
//---------------------------------/

import java.io.IOException;
import java.io.Reader;
import java.io.Serializable;
import java.io.Writer;
import org.exolab.castor.xml.MarshalException;
import org.exolab.castor.xml.Marshaller;
import org.exolab.castor.xml.Unmarshaller;
import org.exolab.castor.xml.ValidationException;
import org.xml.sax.ContentHandler;

/**
 * Class RefactoringEvent.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:39 $
 */
public class RefactoringEvent implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _oldWeb
     */
    private java.lang.String _oldWeb;

    /**
     * Field _oldName
     */
    private java.lang.String _oldName;

    /**
     * Field _oldParent
     */
    private java.lang.String _oldParent;

    /**
     * Field _newWeb
     */
    private java.lang.String _newWeb;

    /**
     * Field _newName
     */
    private java.lang.String _newName;

    /**
     * Field _newParent
     */
    private java.lang.String _newParent;

    /**
     * Field _operation
     */
    private java.lang.String _operation;


      //----------------/
     //- Constructors -/
    //----------------/

    public RefactoringEvent() {
        super();
    } //-- twikilistener.message.RefactoringEvent()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Returns the value of field 'newName'.
     * 
     * @return the value of field 'newName'.
     */
    public java.lang.String getNewName()
    {
        return this._newName;
    } //-- java.lang.String getNewName() 

    /**
     * Returns the value of field 'newParent'.
     * 
     * @return the value of field 'newParent'.
     */
    public java.lang.String getNewParent()
    {
        return this._newParent;
    } //-- java.lang.String getNewParent() 

    /**
     * Returns the value of field 'newWeb'.
     * 
     * @return the value of field 'newWeb'.
     */
    public java.lang.String getNewWeb()
    {
        return this._newWeb;
    } //-- java.lang.String getNewWeb() 

    /**
     * Returns the value of field 'oldName'.
     * 
     * @return the value of field 'oldName'.
     */
    public java.lang.String getOldName()
    {
        return this._oldName;
    } //-- java.lang.String getOldName() 

    /**
     * Returns the value of field 'oldParent'.
     * 
     * @return the value of field 'oldParent'.
     */
    public java.lang.String getOldParent()
    {
        return this._oldParent;
    } //-- java.lang.String getOldParent() 

    /**
     * Returns the value of field 'oldWeb'.
     * 
     * @return the value of field 'oldWeb'.
     */
    public java.lang.String getOldWeb()
    {
        return this._oldWeb;
    } //-- java.lang.String getOldWeb() 

    /**
     * Returns the value of field 'operation'.
     * 
     * @return the value of field 'operation'.
     */
    public java.lang.String getOperation()
    {
        return this._operation;
    } //-- java.lang.String getOperation() 

    /**
     * Method isValid
     */
    public boolean isValid()
    {
        try {
            validate();
        }
        catch (org.exolab.castor.xml.ValidationException vex) {
            return false;
        }
        return true;
    } //-- boolean isValid() 

    /**
     * Method marshal
     * 
     * @param out
     */
    public void marshal(java.io.Writer out)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        
        Marshaller.marshal(this, out);
    } //-- void marshal(java.io.Writer) 

    /**
     * Method marshal
     * 
     * @param handler
     */
    public void marshal(org.xml.sax.ContentHandler handler)
        throws java.io.IOException, org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        
        Marshaller.marshal(this, handler);
    } //-- void marshal(org.xml.sax.ContentHandler) 

    /**
     * Sets the value of field 'newName'.
     * 
     * @param newName the value of field 'newName'.
     */
    public void setNewName(java.lang.String newName)
    {
        this._newName = newName;
    } //-- void setNewName(java.lang.String) 

    /**
     * Sets the value of field 'newParent'.
     * 
     * @param newParent the value of field 'newParent'.
     */
    public void setNewParent(java.lang.String newParent)
    {
        this._newParent = newParent;
    } //-- void setNewParent(java.lang.String) 

    /**
     * Sets the value of field 'newWeb'.
     * 
     * @param newWeb the value of field 'newWeb'.
     */
    public void setNewWeb(java.lang.String newWeb)
    {
        this._newWeb = newWeb;
    } //-- void setNewWeb(java.lang.String) 

    /**
     * Sets the value of field 'oldName'.
     * 
     * @param oldName the value of field 'oldName'.
     */
    public void setOldName(java.lang.String oldName)
    {
        this._oldName = oldName;
    } //-- void setOldName(java.lang.String) 

    /**
     * Sets the value of field 'oldParent'.
     * 
     * @param oldParent the value of field 'oldParent'.
     */
    public void setOldParent(java.lang.String oldParent)
    {
        this._oldParent = oldParent;
    } //-- void setOldParent(java.lang.String) 

    /**
     * Sets the value of field 'oldWeb'.
     * 
     * @param oldWeb the value of field 'oldWeb'.
     */
    public void setOldWeb(java.lang.String oldWeb)
    {
        this._oldWeb = oldWeb;
    } //-- void setOldWeb(java.lang.String) 

    /**
     * Sets the value of field 'operation'.
     * 
     * @param operation the value of field 'operation'.
     */
    public void setOperation(java.lang.String operation)
    {
        this._operation = operation;
    } //-- void setOperation(java.lang.String) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.RefactoringEvent) Unmarshaller.unmarshal(twikilistener.message.RefactoringEvent.class, reader);
    } //-- java.lang.Object unmarshal(java.io.Reader) 

    /**
     * Method validate
     */
    public void validate()
        throws org.exolab.castor.xml.ValidationException
    {
        org.exolab.castor.xml.Validator validator = new org.exolab.castor.xml.Validator();
        validator.validate(this);
    } //-- void validate() 

}
