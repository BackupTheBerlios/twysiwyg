/**
 * ServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 * Modified to configure service's endpoint
 */

package fr.unice.twikiservice;

public class ServiceLocator extends org.apache.axis.client.Service implements fr.unice.twikiservice.Service {

    // Use to get a proxy class for ServicePortType
    private java.lang.String ServicePortType_address;

    public ServiceLocator(java.lang.String ServicePortType_address) {
        this.ServicePortType_address = ServicePortType_address;
    }

    public java.lang.String getServicePortTypeAddress() {
        return ServicePortType_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String ServicePortTypeWSDDServiceName = "ServicePortType";

    public java.lang.String getServicePortTypeWSDDServiceName() {
        return ServicePortTypeWSDDServiceName;
    }

    public void setServicePortTypeWSDDServiceName(java.lang.String name) {
        ServicePortTypeWSDDServiceName = name;
    }

    public fr.unice.twikiservice.ServicePortType getServicePortType() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(ServicePortType_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getServicePortType(endpoint);
    }

    public fr.unice.twikiservice.ServicePortType getServicePortType(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            fr.unice.twikiservice.BindingStub _stub = new fr.unice.twikiservice.BindingStub(portAddress, this);
            _stub.setPortName(getServicePortTypeWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (fr.unice.twikiservice.ServicePortType.class.isAssignableFrom(serviceEndpointInterface)) {
                fr.unice.twikiservice.BindingStub _stub = new fr.unice.twikiservice.BindingStub(new java.net.URL(ServicePortType_address), this);
                _stub.setPortName(getServicePortTypeWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        String inputPortName = portName.getLocalPart();
        if ("ServicePortType".equals(inputPortName)) {
            return getServicePortType();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://twikiservice.unice.fr", "Service");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("ServicePortType"));
        }
        return ports.iterator();
    }

}
