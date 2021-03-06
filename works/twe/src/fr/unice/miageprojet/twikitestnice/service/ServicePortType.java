/**
 * ServicePortType.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package fr.unice.miageprojet.twikitestnice.service;

public interface ServicePortType extends java.rmi.Remote {
    public fr.unice.miageprojet.twikitestnice.service.ConnectionInfo connect(java.lang.String usage, java.lang.String username, java.lang.String password) throws java.rmi.RemoteException;
    public fr.unice.miageprojet.twikitestnice.service.User[] getUsers() throws java.rmi.RemoteException;
    public boolean disconnect(int key) throws java.rmi.RemoteException;
    public boolean subscribe(int key, int port) throws java.rmi.RemoteException;
    public boolean removeSubscription(int key) throws java.rmi.RemoteException;
    public java.lang.String[] getWebs(java.lang.String root) throws java.rmi.RemoteException;
    public boolean ping(int key) throws java.rmi.RemoteException;
    public int renameTopic(int key, java.lang.String web, java.lang.String topic, java.lang.String name, int update) throws java.rmi.RemoteException;
    public boolean lockTopic(int key, java.lang.String web, java.lang.String topic, boolean doLock) throws java.rmi.RemoteException;
    public int moveTopic(int key, java.lang.String oldWeb, java.lang.String topic, java.lang.String newWeb, java.lang.String newParent, int update) throws java.rmi.RemoteException;
    public int removeTopic(int key, java.lang.String web, java.lang.String topic, int option, java.lang.String trashName) throws java.rmi.RemoteException;
    public int mergeTopics(int key, java.lang.String webTarget, java.lang.String topicTarget, java.lang.String webFrom, java.lang.String topicFrom, boolean attachments, boolean identify, int removeOption, boolean dontNotify) throws java.rmi.RemoteException;
    public int copyTopic(int key, java.lang.String srcWeb, java.lang.String topic, java.lang.String dstWeb, java.lang.String newName, java.lang.String parent, boolean attachments) throws java.rmi.RemoteException;
    public boolean setAdminLock(int key, boolean doLock) throws java.rmi.RemoteException;
    public int setTopic(int key, fr.unice.miageprojet.twikitestnice.service.Topic topic, boolean doKeep, boolean doUnlock, boolean dontNotify) throws java.rmi.RemoteException;
    public java.lang.String[] giveHierarchy(java.lang.String path) throws java.rmi.RemoteException;
    public int giveWebProperties(java.lang.String chaineweb) throws java.rmi.RemoteException;
    public java.lang.String[] giveTopicProperties(java.lang.String chainetopic) throws java.rmi.RemoteException;
    public java.lang.String[] sameTopicParent(java.lang.String nameTopic) throws java.rmi.RemoteException;
    public java.lang.String sayHello(java.lang.String sHellop) throws java.rmi.RemoteException;
    public fr.unice.miageprojet.twikitestnice.service.Topic getTopic(java.lang.String topicpa) throws java.rmi.RemoteException;
    public fr.unice.miageprojet.twikitestnice.service.Attachment getAttach(java.lang.String attachpp, java.lang.String attachpf) throws java.rmi.RemoteException;
    public java.lang.String[] getListAttach(java.lang.String attachpl) throws java.rmi.RemoteException;
}
