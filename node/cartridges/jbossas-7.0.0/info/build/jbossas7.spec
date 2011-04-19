%define jboss_version_full 7.0.0.Beta2

Summary:        JBoss Application Server
Name:           jboss-as7
Version:        7.0.0.Beta2
Release:        1
License:        LGPL
BuildArch:      noarch
Group:          Applications/System
Source0:        jboss-%{version}.tar.gz
Requires:       shadow-utils
Requires:       coreutils
Requires:       java-1.6.0-openjdk >= 1:1.6.0.0-1.39
Requires:       initscripts
Requires(post): /sbin/chkconfig
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root

%define __jar_repack %{nil}

%description
The JBoss Application Server

# Ignore warnings about arch binary dependencies
%global _binaries_in_noarch_packages_terminate_build 0

%prep
%setup -n jboss-%{version}

%install
cd %{_topdir}/BUILD

install -d -m 755 $RPM_BUILD_ROOT/opt/jboss-%{version}
cp -R jboss-%{version}/* $RPM_BUILD_ROOT/opt/jboss-%{version}

%clean
rm -Rf $RPM_BUILD_ROOT

%pre

%post

%files
%defattr(-,root,root)
/

%changelog
* Mon Apr 18 2011 Scott Stark
- Update the java-1.6.0-openjdk requires to need build 1.39 or higher
* Thu Mar 31 2011 Scott Stark
- Upgrade to upstream 7.0.0.Beta2 release