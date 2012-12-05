EAP6 Standalone SOE
===================
This is my attempt to create an EAP6 based SOE that can work with a master Revision in SVN on-site and
the EAP6 RPM Channel, that is available through our Customer Portal. The Customer can decide from which source
he wants to operate.

This Repository contains EAP 6.0.0 as a master Revision. I mainly use it for testing that alle the packaging works as
expected.

Below you find the default Directory Layout of the Build Environment. I have provided a README in each of the directories.

    .
    ├── build
    ├── doc
    ├── jboss-eap6-master
    └── tools

build
-----
The build Directory is the main work area for the RPM Generation Process. ZIP Support is planned, as well as an improved
service script, but Windows has been out-of-scope for my current engagement.

The build Directory contains the profile configuration, as well as default modules, etc.

doc
---
This Directory contains a general README with instructions on how to use the files in the build directory

jboss-eap-master
----------------
Self explanatory... This is the JBoss EAP 6.0.0 Master Revision. This Repository is only used to build the base RPM
Package, and provides the default standalone.xml, standalone-ha.xml, standalone-full.xml, standalone-full-ha.xml. This
has to be downloaded and extracted from the Customer Support Portal (http://access.redhat.com). And you need a valid
 subscription for it.

tools
-----
This Directory contains Apache Ant 1.8.4, as well as all need submodules (XmlTask, svnant, ant-contrib) These were needed
to implement every necessary use case within ant.