/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: Issuer.java,v 1.1 2004/09/06 10:29:38 romano Exp $
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
 * Class Issuer.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:38 $
 */
public class Issuer implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _login
     */
    private java.lang.String _login;

    /**
     * Field _address
     */
    private twikilistener.message.Address _address;


      //----------------/
     //- Constructors -/
    //----------------/

    public Issuer() {
        super();
    } //-- twikilistener.message.Issuer()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Returns the value of field 'address'.
     * 
     * @return the value of field 'address'.
     */
    public twikilistener.message.Address getAddress()
    {
        return this._address;
    } //-- twikilistener.message.Address getAddress() 

    /**
     * Returns the value of field 'login'.
     * 
     * @return the value of field 'login'.
     */
    public java.lang.String getLogin()
    {
        return this._login;
    } //-- java.lang.String getLogin() 

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
     * Sets the value of field 'address'.
     * 
     * @param address the value of field 'address'.
     */
    public void setAddress(twikilistener.message.Address address)
    {
        this._address = address;
    } //-- void setAddress(twikilistener.message.Address) 

    /**
     * Sets the value of field 'login'.
     * 
     * @param login the value of field 'login'.
     */
    public void setLogin(java.lang.String login)
    {
        this._login = login;
    } //-- void setLogin(java.lang.String) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.Issuer) Unmarshaller.unmarshal(twikilistener.message.Issuer.class, reader);
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
