/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: ConnectionEvent.java,v 1.1 2004/09/06 10:29:37 romano Exp $
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
 * Class ConnectionEvent.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:37 $
 */
public class ConnectionEvent implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _connected
     */
    private boolean _connected;

    /**
     * keeps track of state for field: _connected
     */
    private boolean _has_connected;


      //----------------/
     //- Constructors -/
    //----------------/

    public ConnectionEvent() {
        super();
    } //-- twikilistener.message.ConnectionEvent()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Method deleteConnected
     */
    public void deleteConnected()
    {
        this._has_connected= false;
    } //-- void deleteConnected() 

    /**
     * Returns the value of field 'connected'.
     * 
     * @return the value of field 'connected'.
     */
    public boolean getConnected()
    {
        return this._connected;
    } //-- boolean getConnected() 

    /**
     * Method hasConnected
     */
    public boolean hasConnected()
    {
        return this._has_connected;
    } //-- boolean hasConnected() 

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
     * Sets the value of field 'connected'.
     * 
     * @param connected the value of field 'connected'.
     */
    public void setConnected(boolean connected)
    {
        this._connected = connected;
        this._has_connected = true;
    } //-- void setConnected(boolean) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.ConnectionEvent) Unmarshaller.unmarshal(twikilistener.message.ConnectionEvent.class, reader);
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
