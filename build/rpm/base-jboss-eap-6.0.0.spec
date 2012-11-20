##
## RPM spec file to generate the jbossas RPM package for Bosch Platform Release 
## This package provides base JBoss Enterprise Application Platform
##
## Author: Juergen Hoffmann <jhoffmann@redhat.com>
##
## Define some utility variables that are used by RPM withing this spec file.
## The tokenized variables with @@ are replaced by ant build script at runtime.
##
%define projectName @RELEASE_NAME@
%define pkg_namesuffix @PROFILE_NAME@

%define pkg_name jboss-eap-base
%define pkg_version @PACKAGE_VERSION@
%define pkg_release @PACKAGE_RELEASE@
%define pkg_root @INSTALL_ROOT@
%define pkg_basedir @INSTALL_PREFIX@
%define pkg_includedir @PACKAGE_BASEDIR@

#### Define user and group for the installed files.
%define boschuser @RUNAS_USER@
%define boschgroup @RUNAS_GROUP@

Name:      %{pkg_name}
Version:   %{pkg_version}
Release:   %{pkg_release}
Epoch:     0
Summary:   Bosch Custom JBoss EAP Build
Vendor:    Bosch
BuildArch: x86_64
Packager:  Juergen Hoffmann <jhoffmann@redhat.com>

Group:     Internet/WWW/Servers
License:   Bosch License
URL:       http://support.redhat.com/
Source0:   %{pkg_namesuffix}-%{projectName}.tar
BuildRoot: %{_topdir}/buildroot/%{name}-%{version}

## Turn off for safety reasons.
AutoReq: off

#Requires: %{projectName}-tools 
#Requires: %{projectName}-tools >= %{pkg_version}

# Do not provide too much stuff and screw up other dependencies
AutoProv: off
Provides: %{name} = %{version}
Requires: apr

%description
Base JBoss Enterprise Application Platform version %{version} 
Software distribution for Bosch v@PACKAGE_VERSION@ Release

%prep
%setup -n %{projectName}

%install
mkdir -p $RPM_BUILD_ROOT%{pkg_basedir}/jboss-as

## Install base jboss-as directory
## Copy / deploy / install the required files and directories
cp -r jboss-as $RPM_BUILD_ROOT%{pkg_basedir}/
%{__install} -d -m 0755 $RPM_BUILD_ROOT%{pkg_basedir}/jboss-as
%{__rm} -rf %{_tmppath}/jboss-eap-base.filelist
find $RPM_BUILD_ROOT%{pkg_basedir}/jboss-as -type d | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#%dir "\1"#g;}' >>%{_tmppath}/jboss-eap-base.filelist
find $RPM_BUILD_ROOT%{pkg_basedir}/jboss-as -type f | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#"\1"#g;}' >>%{_tmppath}/jboss-eap-base.filelist

%preun
if [ $1 = 0 ]; then
	unlink %{pkg_root}/jboss
fi

%post
chmod 0755 $RPM_BUILD_ROOT%{pkg_basedir}/jboss-as/bin/*.sh
## symbolic link to jboss-as
if [ -h %{pkg_root}/jboss ]; then
	unlink %{pkg_root}/jboss
fi
ln -s %{pkg_basedir}/jboss-as %{pkg_root}/jboss

%clean
# Clean up the RPM build root directory.
%{__rm} -rf $RPM_BUILD_ROOT
%{__rm} -rf %{_tmppath}/jboss-eap-base.filelist

#### Files for main jbossas package.
%files -f %{_tmppath}/jboss-eap-base.filelist
%dir %{pkg_basedir}
%defattr(-,%{boschuser},%{boschgroup},-)

%changelog
* Thu Nov 08 2012 Juergen Hoffmann <jhoffmann@redhat.com> - 0:5.0.1-2
- initial RPM spec file

* Mon Aug 01 2011 Torben Jaeger <torben@redhat.com> - 0:5.0.1-1
- initial RPM spec file
