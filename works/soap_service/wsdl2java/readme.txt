WSDL2Java generate stubs and Java data structures from the WSDL file given. Here is the command line
to launch WSDL2Java script :

> run lib_path wsdl_file

lib_path is the location (no "\" at the end) where java can find these .jar (Apache Axis/WSIF) :

- Axis.jar
- commons-logging.jar
- wsdl4j.jar
- jaxrpc.jar
- soap.jar
- saaj.jar

If you have JBuilder installed for example, you can specify JBUILDER_PATH\lib.

Modifications are required in generated stubs. In ServiceLocator.java :

< private final java.lang.String ServicePortType_address = "http://miageprojet.unice.fr/twikitestnice/bin/service";

> private java.lang.String ServicePortType_address;
> 
> public ServiceLocator(java.lang.String ServicePortType_address) {
>	this.ServicePortType_address = ServicePortType_address;
> }

< = Remove
> = add

ServiceTestCase.java could be removed.