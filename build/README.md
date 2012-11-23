Build Directory
===============
This Directory holds the magic stuff. This is where you configure your profiles, modules, etc. Let me explain this layout.

    .
    ├── blueprints
    ├── profiles
    ├── rpm
    ├── README.md
    ├── build.properties
    ├── build.xml
    ├── macros.xml
    ├── rpm-sign.exp
    ├── runbuild.sh
    ├── sat-upload.sh
    └── standalone-parsed.xml

blueprints
----------
Contains default modules and custom profile properties.

    blueprints/
    ├── default-modules
    │   ├── jtds
    │   │   └── net
    │   │       └── sourceforge
    │   │           └── jtds
    │   │               └── main
    │   │                   ├── jtds-1.3.0.jar
    │   │                   └── module.xml
    │   ├── microsoft
    │   │   └── com
    │   │       └── microsoft
    │   │           └── jdbc
    │   │               └── main
    │   │                   ├── module.xml
    │   │                   └── sqljdbc4.jar
    │   ├── mysql
    │   │   └── com
    │   │       └── mysql
    │   │           └── jdbc
    │   │               └── main
    │   │                   ├── module.xml
    │   │                   └── mysql-connector-java-5.1.7-bin.jar
    │   └── oracle
    │       └── com
    │           └── oracle
    │               └── ojdbc6
    │                   └── main
    │                       ├── module.xml
    │                       └── ojdbc16_11g-2-0-1.jar
    ├── other
    │   ├── jtds.xml
    │   ├── mssql.xml
    │   ├── mysql.xml
    │   ├── oracle.xml
    │   └── socket-binding-group.xml
    ├── subsystems
    │   ├── deployment-scanner.xml
    │   ├── logging.xml
    │   ├── mail.xml
    │   ├── threads.xml
    │   └── web.xml
    ├── INFO.txt
    ├── custom.properties
    ├── jboss-as-standalone.sh
    └── jboss-as.conf

As you can see, you have the ability to add custom modules. Please understand that this SOE follows the concept of
marker files. Marker Files allow the dynamic creation of profiles. I will explain more about this later. The README
in the Directory contains more information.

profiles
--------
This Directory contains the profile configuration. Each Profile should be created in a Sub Directory. There are a couple
of Example Properties already installed.

rpm
---
This Directory contains the RPM Specfiles which are used to build the RPM Package.

Files
=====

    ├── build.properties.template
    ├── build.xml
    ├── macros.xml
    ├── rpm-sign.exp
    ├── runbuild.sh
    └── sat-upload.sh

build.properties.template
-------------------------
Main configuration file for the build environment. This SOE is capable to handle the official RHN RPM Channel as well as
the jboss-eap6-master Version, which is checked into the RVCS. The build process uses svnant to check out the Master Revision
I have tried to add comments as explaining as possible.

build.xml
---------
Main build file - I still have to rework the process-profile target, which is the main target that is doing most of
the work.

macros.xml
----------
This file will hold the re-factored targets, that are common and should not be present in a specialized build.xml file
Think of this as being a Library.

rpm-sign.exp
------------
expect script to automate password entry for the RPM Signing process. Hence removes the burden to enter your password
every time you build a profile

runbuild.sh
-----------
This is a shell-wrapper script, that sets up the ANT environment and simply calls it. It addes the parameter
-projecthelp, if called without any arguments

sat-upload.sh
-------------
This script has to be modified for each installation. It is resposible to upload the created RPM Packages to the Satellite