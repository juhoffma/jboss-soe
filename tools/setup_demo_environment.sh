#!/usr/bin/env bash
set -e

# This script will setup a demo environment for you.
# Written by Juergen Hoffmann <jhoffmann@redhat.com>
#
# IMPORTANT!!!! This Script should be run inside a pristine VM
# because the script will install certain required RPMs to get you started
#
# WHAT WILL IT DO???
# - it will install all required RPMs to run the build
# - configure an apache based Subversion Server
# - create an initial revision with your current master revision
# - create 2 directories /tmp/svn-work and /tmp/svn-build
# - make access to your local SVN Repository via Basic Auth

# Install all necessary packages
yum install git rpm-build subversion httpd java-1.6.0-openjdk-devel mod_dav_svn mc subversion-javahl -y

# This is where we are going to keep the repo
mkdir -p /var/local/svn

# create the repository
svnadmin create /var/local/svn/test

# Make sure we have the correct properties set
chown -R apache.apache /var/local/svn/
chcon -R -t httpd_sys_content_t /var/local/svn

# clone the jboss-soe repository
mkdir /tmp/jboss-soe
git clone https://github.com/juhoffma/jboss-soe.git /tmp/jboss-soe

# Configure the Apache SVN Module
cat > /etc/httpd/conf.d/subversion.conf <<EOF
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so


<Location /svn>
   DAV svn
   SVNParentPath /var/local/svn

   # Limit write permission to list of valid users.
   <LimitExcept GET PROPFIND OPTIONS REPORT>
      # Require SSL connection for password protection.
      # SSLRequireSSL

      AuthType Basic
      AuthName "Authorization Realm"
      AuthUserFile /etc/httpd/subversion_users
      Require valid-user
   </LimitExcept>
</Location>
EOF

# Restart HTTP Server
service httpd restart

# Create the test user account for the subversion repository
htpasswd -b -c /etc/httpd/subversion_users test redhat

# Create the initial checkin to the repository
cd /tmp
svn --no-auth-cache --username test --password redhat checkout http://localhost/svn/test
cd test/
mkdir -p trunk/jboss-soe
cp -a /tmp/jboss-soe/build /tmp/jboss-soe/tools /tmp/jboss-soe/doc trunk/jboss-soe
mv trunk/jboss-soe/build/build.properties.template trunk/jboss-soe/build/build.properties
svn add trunk/
svn --no-auth-cache commit --username test --password redhat -m "Initial checkin"

# Getting rid of our prepared initial checkin directory and making sure that everything works from scratch
rm -rf /tmp/test

# Checkout our concrete working copy
mkdir /tmp/svn-work
cd /tmp/svn-work
svn --no-auth-cache --username test --password redhat checkout http://localhost/svn/test/trunk/jboss-soe/

clear

cat <<EOF
Congratulations, Your working copy has been created in /tmp/svn-work
You should start by editing your build.properties in /tmp/svn-work/jboss-soe/build
You should at least set the following properties

svn.repo.url=http://localhost/svn/test/trunk/jboss-soe
svn.repo.user=test
svn.repo.passwd=redhat

build.root=/tmp/svn-build
target.installation.directory=/opt

NOTE!!!
If you do not want to use the RHN Channels for the JBoss EAP6 Version you should download
https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=17633&product=appplatform
unzip it and put it into

/tmp/svn-work/jboss-soe/jboss-eap6-master

so that ls -la /tmp/svn-work/jboss-soe/jboss-eap6-master prints

-rw-rw-r--@  1 buddy  staff     425 20 Nov 15:54 JBossEULA.txt
-rw-rw-r--@  1 buddy  staff   26530 20 Nov 15:54 LICENSE.txt
drwxrwxr-x@  3 buddy  staff     102 20 Nov 15:54 appclient
drwxrwxr-x@ 35 buddy  staff    1190 20 Dez 13:16 bin
drwxrwxr-x@  4 buddy  staff     136 20 Nov 15:54 bundles
drwxrwxr-x@  5 buddy  staff     170 20 Nov 15:54 docs
drwxrwxr-x@  6 buddy  staff     204 18 Jan 12:13 domain
-rw-rw-r--@  1 buddy  staff  267443 20 Nov 15:54 jboss-modules.jar
drwxrwxr-x@ 14 buddy  staff     476 20 Nov 15:54 modules
drwxrwxr-x@  8 buddy  staff     272 17 Jan 13:41 standalone
-rw-rw-r--@  1 buddy  staff      58 20 Nov 15:54 version.txt
drwxrwxr-x@ 10 buddy  staff     340 20 Dez 13:16 welcome-content

and uncomment the option

#master.revision.specfile.name=base-jboss-eap6.spec
#profile.requires.upstream=jboss-eap-base
#profile.requires.upstream.version=${eap.version}

and comment

profile.requires.upstream=jbossas-product-eap
profile.requires.upstream.version=7.1.2


EOF