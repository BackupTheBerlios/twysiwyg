/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: Message.java,v 1.1 2004/09/06 10:29:39 romano Exp $
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
 * Class Message.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:39 $
 */
public class Message implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _type
     */
    private int _type;

    /**
     * keeps track of state for field: _type
     */
    private boolean _has_type;

    /**
     * Field _issuer
     */
    private twikilistener.message.Issuer _issuer;

    /**
     * Field _text
     */
    private java.lang.String _text;

    /**
     * Field _event
     */
    private twikilistener.message.Event _event;


      //----------------/
     //- Constructors -/
    //----------------/

    public Message() {
        super();
    } //-- twikilistener.message.Message()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Method deleteType
     */
    public void deleteType()
    {
        this._has_type= false;
    } //-- void deleteType() 

    /**
     * Returns the value of field 'event'.
     * 
     * @return the value of field 'event'.
     */
    public twikilistener.message.Event getEvent()
    {
        return this._event;
    } //-- twikilistener.message.Event getEvent() 

    /**
     * Returns the value of field 'issuer'.
     * 
     * @return the value of field 'issuer'.
     */
    public twikilistener.message.Issuer getIssuer()
    {
        return this._issuer;
    } //-- twikilistener.message.Issuer getIssuer() 

    /**
     * Returns the value of field 'text'.
     * 
     * @return the value of field 'text'.
     */
    public java.lang.String getText()
    {
        return this._text;
    } //-- java.lang.String getText() 

    /**
     * Returns the value of field 'type'.
     * 
     * @return the value of field 'type'.
     */
    public int getType()
    {
        return this._type;
    } //-- int getType() 

    /**
     * Method hasType
     */
    public boolean hasType()
    {
        return this._has_type;
    } //-- boolean hasType() 

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
     * Sets the value of field 'event'.
     * 
     * @param event the value of field 'event'.
     */
    public void setEvent(twikilistener.message.Event event)
    {
        this._event = event;
    } //-- void setEvent(twikilistener.message.Event) 

    /**
     * Sets the value of field 'issuer'.
     * 
     * @param issuer the value of field 'issuer'.
     */
    public void setIssuer(twikilistener.message.Issuer issuer)
    {
        this._issuer = issuer;
    } //-- void setIssuer(twikilistener.message.Issuer) 

    /**
     * Sets the value of field 'text'.
     * 
     * @param text the value of field 'text'.
     */
    public void setText(java.lang.String text)
    {
        this._text = text;
    } //-- void setText(java.lang.String) 

    /**
     * Sets the value of field 'type'.
     * 
     * @param type the value of field 'type'.
     */
    public void setType(int type)
    {
        this._type = type;
        this._has_type = true;
    } //-- void setType(int) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.Message) Unmarshaller.unmarshal(twikilistener.message.Message.class, reader);
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
