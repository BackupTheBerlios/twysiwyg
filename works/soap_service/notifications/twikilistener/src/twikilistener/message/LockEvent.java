/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: LockEvent.java,v 1.1 2004/09/06 10:29:38 romano Exp $
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
 * Class LockEvent.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:38 $
 */
public class LockEvent implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _locked
     */
    private boolean _locked;

    /**
     * keeps track of state for field: _locked
     */
    private boolean _has_locked;

    /**
     * Field _lock
     */
    private java.lang.String _lock;


      //----------------/
     //- Constructors -/
    //----------------/

    public LockEvent() {
        super();
    } //-- twikilistener.message.LockEvent()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Method deleteLocked
     */
    public void deleteLocked()
    {
        this._has_locked= false;
    } //-- void deleteLocked() 

    /**
     * Returns the value of field 'lock'.
     * 
     * @return the value of field 'lock'.
     */
    public java.lang.String getLock()
    {
        return this._lock;
    } //-- java.lang.String getLock() 

    /**
     * Returns the value of field 'locked'.
     * 
     * @return the value of field 'locked'.
     */
    public boolean getLocked()
    {
        return this._locked;
    } //-- boolean getLocked() 

    /**
     * Method hasLocked
     */
    public boolean hasLocked()
    {
        return this._has_locked;
    } //-- boolean hasLocked() 

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
     * Sets the value of field 'lock'.
     * 
     * @param lock the value of field 'lock'.
     */
    public void setLock(java.lang.String lock)
    {
        this._lock = lock;
    } //-- void setLock(java.lang.String) 

    /**
     * Sets the value of field 'locked'.
     * 
     * @param locked the value of field 'locked'.
     */
    public void setLocked(boolean locked)
    {
        this._locked = locked;
        this._has_locked = true;
    } //-- void setLocked(boolean) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.LockEvent) Unmarshaller.unmarshal(twikilistener.message.LockEvent.class, reader);
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
