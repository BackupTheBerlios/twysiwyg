/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: Address.java,v 1.1 2004/09/06 10:29:37 romano Exp $
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
 * Class Address.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:37 $
 */
public class Address implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _ip
     */
    private java.lang.String _ip;

    /**
     * Field _port
     */
    private int _port;

    /**
     * keeps track of state for field: _port
     */
    private boolean _has_port;


      //----------------/
     //- Constructors -/
    //----------------/

    public Address() {
        super();
    } //-- twikilistener.message.Address()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Method deletePort
     */
    public void deletePort()
    {
        this._has_port= false;
    } //-- void deletePort() 

    /**
     * Returns the value of field 'ip'.
     * 
     * @return the value of field 'ip'.
     */
    public java.lang.String getIp()
    {
        return this._ip;
    } //-- java.lang.String getIp() 

    /**
     * Returns the value of field 'port'.
     * 
     * @return the value of field 'port'.
     */
    public int getPort()
    {
        return this._port;
    } //-- int getPort() 

    /**
     * Method hasPort
     */
    public boolean hasPort()
    {
        return this._has_port;
    } //-- boolean hasPort() 

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
     * Sets the value of field 'ip'.
     * 
     * @param ip the value of field 'ip'.
     */
    public void setIp(java.lang.String ip)
    {
        this._ip = ip;
    } //-- void setIp(java.lang.String) 

    /**
     * Sets the value of field 'port'.
     * 
     * @param port the value of field 'port'.
     */
    public void setPort(int port)
    {
        this._port = port;
        this._has_port = true;
    } //-- void setPort(int) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.Address) Unmarshaller.unmarshal(twikilistener.message.Address.class, reader);
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
