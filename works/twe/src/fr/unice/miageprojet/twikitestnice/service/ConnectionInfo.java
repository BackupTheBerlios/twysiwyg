/**
 * ConnectionInfo.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package fr.unice.miageprojet.twikitestnice.service;

public class ConnectionInfo  implements java.io.Serializable {
    private int key;
    private int timeout;
    private boolean subwebs;
    private boolean adminLock;
    private boolean locksActualization;
    private boolean completeRemoveAllowed;

    public ConnectionInfo() {
    }

    public int getKey() {
        return key;
    }

    public void setKey(int key) {
        this.key = key;
    }

    public int getTimeout() {
        return timeout;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }

    public boolean isSubwebs() {
        return subwebs;
    }

    public void setSubwebs(boolean subwebs) {
        this.subwebs = subwebs;
    }

    public boolean isAdminLock() {
        return adminLock;
    }

    public void setAdminLock(boolean adminLock) {
        this.adminLock = adminLock;
    }

    public boolean isLocksActualization() {
        return locksActualization;
    }

    public void setLocksActualization(boolean locksActualization) {
        this.locksActualization = locksActualization;
    }

    public boolean isCompleteRemoveAllowed() {
        return completeRemoveAllowed;
    }

    public void setCompleteRemoveAllowed(boolean completeRemoveAllowed) {
        this.completeRemoveAllowed = completeRemoveAllowed;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof ConnectionInfo)) return false;
        ConnectionInfo other = (ConnectionInfo) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            this.key == other.getKey() &&
            this.timeout == other.getTimeout() &&
            this.subwebs == other.isSubwebs() &&
            this.adminLock == other.isAdminLock() &&
            this.locksActualization == other.isLocksActualization() &&
            this.completeRemoveAllowed == other.isCompleteRemoveAllowed();
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        _hashCode += getKey();
        _hashCode += getTimeout();
        _hashCode += new Boolean(isSubwebs()).hashCode();
        _hashCode += new Boolean(isAdminLock()).hashCode();
        _hashCode += new Boolean(isLocksActualization()).hashCode();
        _hashCode += new Boolean(isCompleteRemoveAllowed()).hashCode();
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(ConnectionInfo.class);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://miageprojet.unice.fr/twikitestnice/service", "ConnectionInfo"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("key");
        elemField.setXmlName(new javax.xml.namespace.QName("", "key"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "int"));
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("timeout");
        elemField.setXmlName(new javax.xml.namespace.QName("", "timeout"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "int"));
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("subwebs");
        elemField.setXmlName(new javax.xml.namespace.QName("", "subwebs"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("adminLock");
        elemField.setXmlName(new javax.xml.namespace.QName("", "adminLock"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("locksActualization");
        elemField.setXmlName(new javax.xml.namespace.QName("", "locksActualization"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("completeRemoveAllowed");
        elemField.setXmlName(new javax.xml.namespace.QName("", "completeRemoveAllowed"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        typeDesc.addFieldDesc(elemField);
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
