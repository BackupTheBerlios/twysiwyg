/*
 * This class was automatically generated with 
 * <a href="http://www.castor.org">Castor 0.9.5.3</a>, using an XML
 * Schema.
 * $Id: Event.java,v 1.1 2004/09/06 10:29:37 romano Exp $
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
 * Class Event.
 * 
 * @version $Revision: 1.1 $ $Date: 2004/09/06 10:29:37 $
 */
public class Event implements java.io.Serializable {


      //--------------------------/
     //- Class/Member Variables -/
    //--------------------------/

    /**
     * Field _connectionEvent
     */
    private twikilistener.message.ConnectionEvent _connectionEvent;

    /**
     * Field _lockEvent
     */
    private twikilistener.message.LockEvent _lockEvent;

    /**
     * Field _refactoringEvent
     */
    private twikilistener.message.RefactoringEvent _refactoringEvent;

    /**
     * Field _topicEvent
     */
    private twikilistener.message.TopicEvent _topicEvent;


      //----------------/
     //- Constructors -/
    //----------------/

    public Event() {
        super();
    } //-- twikilistener.message.Event()


      //-----------/
     //- Methods -/
    //-----------/

    /**
     * Returns the value of field 'connectionEvent'.
     * 
     * @return the value of field 'connectionEvent'.
     */
    public twikilistener.message.ConnectionEvent getConnectionEvent()
    {
        return this._connectionEvent;
    } //-- twikilistener.message.ConnectionEvent getConnectionEvent() 

    /**
     * Returns the value of field 'lockEvent'.
     * 
     * @return the value of field 'lockEvent'.
     */
    public twikilistener.message.LockEvent getLockEvent()
    {
        return this._lockEvent;
    } //-- twikilistener.message.LockEvent getLockEvent() 

    /**
     * Returns the value of field 'refactoringEvent'.
     * 
     * @return the value of field 'refactoringEvent'.
     */
    public twikilistener.message.RefactoringEvent getRefactoringEvent()
    {
        return this._refactoringEvent;
    } //-- twikilistener.message.RefactoringEvent getRefactoringEvent() 

    /**
     * Returns the value of field 'topicEvent'.
     * 
     * @return the value of field 'topicEvent'.
     */
    public twikilistener.message.TopicEvent getTopicEvent()
    {
        return this._topicEvent;
    } //-- twikilistener.message.TopicEvent getTopicEvent() 

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
     * Sets the value of field 'connectionEvent'.
     * 
     * @param connectionEvent the value of field 'connectionEvent'.
     */
    public void setConnectionEvent(twikilistener.message.ConnectionEvent connectionEvent)
    {
        this._connectionEvent = connectionEvent;
    } //-- void setConnectionEvent(twikilistener.message.ConnectionEvent) 

    /**
     * Sets the value of field 'lockEvent'.
     * 
     * @param lockEvent the value of field 'lockEvent'.
     */
    public void setLockEvent(twikilistener.message.LockEvent lockEvent)
    {
        this._lockEvent = lockEvent;
    } //-- void setLockEvent(twikilistener.message.LockEvent) 

    /**
     * Sets the value of field 'refactoringEvent'.
     * 
     * @param refactoringEvent the value of field 'refactoringEvent'
     */
    public void setRefactoringEvent(twikilistener.message.RefactoringEvent refactoringEvent)
    {
        this._refactoringEvent = refactoringEvent;
    } //-- void setRefactoringEvent(twikilistener.message.RefactoringEvent) 

    /**
     * Sets the value of field 'topicEvent'.
     * 
     * @param topicEvent the value of field 'topicEvent'.
     */
    public void setTopicEvent(twikilistener.message.TopicEvent topicEvent)
    {
        this._topicEvent = topicEvent;
    } //-- void setTopicEvent(twikilistener.message.TopicEvent) 

    /**
     * Method unmarshal
     * 
     * @param reader
     */
    public static java.lang.Object unmarshal(java.io.Reader reader)
        throws org.exolab.castor.xml.MarshalException, org.exolab.castor.xml.ValidationException
    {
        return (twikilistener.message.Event) Unmarshaller.unmarshal(twikilistener.message.Event.class, reader);
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
