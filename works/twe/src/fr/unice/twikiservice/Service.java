/**
 * Service.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package fr.unice.twikiservice;

public interface Service extends javax.xml.rpc.Service {
    public java.lang.String getServicePortTypeAddress();

    public fr.unice.twikiservice.ServicePortType getServicePortType() throws javax.xml.rpc.ServiceException;

    public fr.unice.twikiservice.ServicePortType getServicePortType(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
