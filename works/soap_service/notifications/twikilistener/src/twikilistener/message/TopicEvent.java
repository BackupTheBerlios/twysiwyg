/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: TopicEvent.java,v 1.1 2004/09/06 10:29:40 romano Exp $
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
 * Class TopicEvent.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:40 $
 */
public class TopicEvent implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _web
     */
    private java.lang.String _web;

    /**
     * Field _name
     */
    private java.lang.String _name;

    /**
     * Field _operation
     */
    private java.lang.String _operation;


      //----------------/
     //- Constructors -/
    //----------------/

    public TopicEvent() {
        super();
    } //-- twikilistener.message.TopicEvent()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Returns the value of field 'name'.
     * 
     * @return the value of field 'name'.
     */
    public java.lang.String getName()
    {
        return this._name;
    } //-- java.lang.String getName() 

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
     * Returns the value of field 'web'.
     * 
     * @return the value of field 'web'.
     */
    public java.lang.String getWeb()
    {
        return this._web;
    } //-- java.lang.String getWeb() 

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
     * Sets the value of field 'name'.
     * 
     * @param name the value of field 'name'.
     */
    public void setName(java.lang.String name)
    {
        this._name = name;
    } //-- void setName(java.lang.String) 

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
     * Sets the value of field 'web'.
     * 
     * @param web the value of field 'web'.
     */
    public void setWeb(java.lang.String web)
    {
        this._web = web;
    } //-- void setWeb(java.lang.String) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.TopicEvent) Unmarshaller.unmarshal(twikilistener.message.TopicEvent.class, reader);
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
