##
## RPM spec file to generate the profile specific RPM packages for 
## Platform Releases 
##
## Author: Juergen Hoffmann <jhoffmann@redhat.com>
##
## Define some utility variables that are used by RPM withing this spec file.
## The tokenized variables with @@ are replaced by ant build script at runtime.
##

%define projectName @RELEASE_NAME@
%define profile_name @PROFILE_NAME@
%define pid_file /var/run/jboss-as/jboss-%{profile_name}.pid

%define pkg_name jboss-eap6-%{profile_name}
%define pkg_version @PACKAGE_VERSION@
%define pkg_release @PACKAGE_RELEASE@
%define pkg_root @INSTALL_ROOT@
%define pkg_basedir @INSTALL_PREFIX@
%define cfg_basedir @CONFIG_BASEDIR@/%{profile_name}


%define jboss_logs @JBOSS_LOG_DIR@/%{profile_name}/jboss-logs
%define app_logs @APP_LOG_DIR@/%{profile_name}

%define runas_user @RUNAS_USER@
%define runas_group @RUNAS_GROUP@

Name:      %{pkg_name}
Version:   %{pkg_version}
Release:   %{pkg_release}
Epoch:     0
Summary:   Custom JBoss EAP Profile Build
Vendor:	   Red Hat
BuildArch: noarch
Packager:  Juergen Hoffmann <jhoffmann@redhat.com>

Group:     Applications/Internet
License:   GPLv3
URL:       http://support.redhat.com/
Source0:   %{profile_name}-%{projectName}.tar
BuildRoot: %{_topdir}/buildroot/%{name}-%{version}

## Turn off for safety reasons.
AutoReq: off
## This is requirement for building the RPM package.
BuildRequires: rpm-build

Requires: @UPSTREAM_RELEASE@ @UPSTREAM_RELEASE_VERSION@

# Do not provide too much stuff and screw up other dependencies
AutoProv: off
Provides: %{name} = %{version}
# virtual pkg name
Provides: jboss-eap6-%{profile_name}

%description
JBoss Enterprise Application Platform %{version} Software.
This package contains a customized JBoss EAP %{version} Server Configuration Profile 
that should be deployed on top of JBoss EAP %{version} package named jboss-eap-base.
The name of profile provided by this package is : "@PROFILE_NAME@"

%prep
%setup -n %{profile_name}

%install
mkdir -p $RPM_BUILD_ROOT%{cfg_basedir}
cp -r * $RPM_BUILD_ROOT%{cfg_basedir}
mkdir -p $RPM_BUILD_ROOT%{cfg_basedir}/log
%{__rm} -rf %{_tmppath}/profile.filelist
find $RPM_BUILD_ROOT%{cfg_basedir} -type d | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#%dir "\1"#g;}' >>%{_tmppath}/profile.filelist
find $RPM_BUILD_ROOT%{cfg_basedir} -type f | sed '{s#'${RPM_BUILD_ROOT}'##;}' | sed '{s#\(^.*$\)#"\1"#g;}' >>%{_tmppath}/profile.filelist

%clean
# Clean up the RPM build root directory.
%{__rm} -rf $RPM_BUILD_ROOT
%{__rm} -rf %{_tmppath}/profile.filelist

%pre
# Add the "jboss" user
getent group %{runas_group} >/dev/null || groupadd -g 1547 -r %{runas_group}
getent passwd %{runas_user} >/dev/null || \
  /usr/sbin/useradd -r -u 1547 -g %{runas_group} -s /sbin/nologin \
  -d %{cfg_basedir} -c "JBoss System user" %{runas_user}

%post
## This condition is true during first installation of package.
if [ $1 -eq 1 ]; then

  ## symlink to sysconfig file
  ln -s %{cfg_basedir}/configuration/jboss_%{profile_name}_sysconfig /etc/sysconfig/jboss_%{profile_name}

  ## Put a profile specific init symlink in /etc/init.d/
  chmod 755 %{cfg_basedir}/configuration/jboss_init_%{profile_name}
  ln -s %{cfg_basedir}/configuration/jboss_init_%{profile_name} /etc/init.d/jboss.%{profile_name}
  chown -R %{runas_user}:%{runas_group} %{cfg_basedir}

  ## Enable profile startup at system boot.
  /sbin/chkconfig --add jboss.%{profile_name}

  ## Create the /data/jboss-logs/%{profile_name} directory
  mkdir -p /data/jboss-logs/%{profile_name}
  chown jboss:jboss /data/jboss-logs/%{profile_name}
fi

## This condition is true if this is last un-install of package.
%preun
if [ $1 = 0 ]; then
  ## Making sure the profile is not running anymore
  if [ -f %{pid_file} ]; then
    read ppid < %{pid_file}
    if [ `ps --pid $ppid 2> /dev/null | grep -c $ppid 2> /dev/null` -eq '1' ]; then
      /etc/init.d/jboss.%{profile_name} stop
    fi
  fi
  /sbin/chkconfig --del jboss.%{profile_name}
  unlink /etc/init.d/jboss.%{profile_name}
  unlink /etc/sysconfig/jboss_%{profile_name}
  rm -rf /data/jboss-logs/%{profile_name}
  rm -rf %{cfg_basedir}
fi

#### Files for the profile packages
%files -f %{_tmppath}/profile.filelist
%defattr(-,%{runas_user},%{runas_group},-)

%changelog
* Wed Nov 07 2012 Juergen Hoffmann <jhoffmann@redhat.com> - 0:5.0.1-1
- initial RPM spec file

