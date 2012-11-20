#!/bin/sh

#############################################################################
## An automated build script to use on UNIX/Linux systems
## Author: Shashin Shinde <sshinde@redhat.com>
##         Juergen Hoffmann <jhoffmann@redhat.com>
#############################################################################

## Should not be run as root.
## Check if the user is root and exit cleanly before hand.
## this has been commented as it is a requirement by the customer
#if [ "$EUID" = "0" ]; then
#   echo "Please use a normal user account and not the root account"
#   exit 1
#fi

## Figure out the checkout location depending upon this script.
SCRIPT_HOME=$(cd `dirname $0` && pwd)
CHECKOUT_HOME=$(cd $SCRIPT_HOME/../ && pwd)

export ANT_HOME=$CHECKOUT_HOME/tools/apache-ant-1.8.4
######### Use SUN JDK 6 6
#export JAVA_HOME=/usr/lib/jvm/java-1.6.0-sun.x86_64
######### Use Open JDK 6
#export JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk.x86_64
#export JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk
export JAVA_HOME=/usr/lib/jvm/java-1.6.0
#export JAVA_HOME=/usr/jdk6/1.6.0_19

# TODO This has to be verified
export COLLABNET_SVN_HOME=/opt/CollabNet_Subversion

## Set up path:
export PATH=${JAVA_HOME}/bin:${ANT_HOME}/bin:${COLLABNET_SVN_HOME}/bin:${PATH}

## Log some of the auto discovered information
echo "Checkout Home is: $CHECKOUT_HOME"
echo "Java Home is: $JAVA_HOME"
echo "Ant Home is: $ANT_HOME"

if [ "x$1" = "x"  ]; then
  ant -f $SCRIPT_HOME/build.xml -projecthelp
else
  ant -f $SCRIPT_HOME/build.xml $*
fi

#createrepo -v `grep rootdir build.properties | awk -F'=' '{print $2;}'`
