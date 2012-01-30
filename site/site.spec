%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Li site components
Name:      rhc-site
Version:   0.85.9
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-site-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: js
BuildRequires: rubygem-coffee-script

Requires:  rhc-common
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  ruby-geoip
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-xml-simple
Requires:  rubygem-formtastic
Requires:  rubygem-haml
Requires:  rubygem-recaptcha
Requires:  rubygem-hpricot
Requires:  rubygem-barista
Requires:  js

BuildArch: noarch

%description
This contains the OpenShift website which manages user authentication,
authorization and also the workflows to request access.

%prep
%setup -q

%build
for x in `/bin/ls ./app/coffeescripts | /bin/grep \.coffee$ | /bin/sed 's/\.coffee$//'`
do
  file="./app/coffeescripts/$x.coffee"
  /usr/bin/ruby -e "require 'rubygems'; require 'coffee_script'; puts CoffeeScript.compile File.read('$file')" > ./public/javascripts/$x.js
done

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{sitedir}
cp -r . %{buildroot}%{sitedir}
ln -s %{sitedir}/public %{buildroot}%{htmldir}/app

mkdir -p %{buildroot}%{sitedir}/run
mkdir -p %{buildroot}%{sitedir}/log
mkdir -p -m 770 %{buildroot}%{sitedir}/tmp
touch %{buildroot}%{sitedir}/log/production.log

%clean
rm -rf %{buildroot}                                

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,root,libra_user) %{sitedir}/log/production.log
%config(noreplace) %{sitedir}/config/environments/production.rb
%{sitedir}
%{htmldir}/app

%post
/bin/touch %{sitedir}/log/production.log
chmod 0770 %{sitedir}/tmp

%changelog
* Sat Jan 28 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- 

* Sat Jan 28 2012 Alex Boone <aboone@redhat.com> 0.85.8-1
- Site build - don't use bundler, install all gems via RPM (aboone@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.7-1
- POST to delete SSH keys instead of DELETE - browser compatibility
  (aboone@redhat.com)
- manage multiple SSH keys via the site control panel (aboone@redhat.com)
- Refactor ExpressApi to expose a class-level http_post method
  (aboone@redhat.com)
- Add a helper to generate URLs to the user guide for future topics
  (ccoleman@redhat.com)
- Another fix for build issue created in 532e0e8 (aboone@redhat.com)
- Fix for 532e0e8, also properly set permissions on logs (aboone@redhat.com)
- Remove therubyracer gem dependency, "js" is already being used
  (aboone@redhat.com)
- Unit tests all pass (ccoleman@redhat.com)
- Make streamline_mock support newer api methods (ccoleman@redhat.com)
- Streamline library changes (ccoleman@redhat.com)
- Provide barista dependencies at site build time (aboone@redhat.com)
- Add BuildRequires: rubygem-crack for site spec (aboone@redhat.com)
- remove old obsoletes (dmcphers@redhat.com)
- Consistently link to the Express Console via /app/control_panel
  (aboone@redhat.com)
- Allow app names up to 32 chars (fix BZ 784454) (aboone@redhat.com)
- remove generated javascript from git; generate during build
  (johnp@redhat.com)
- reflow popups if they are clipped by the document viewport (johnp@redhat.com)
- Fixed JS error 'body not defined' caused by previous commit
  (ccoleman@redhat.com)
- cleanup (dmcphers@redhat.com)

* Tue Jan 25 2012 John (J5) Palmieri <johnp@redhat.com> 0.85.6-1
- remove generated javascript and use rake to generate
  javascript during the build

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.5-1
- Remove floating header to reduce problems on iPad/iPhone
  (ccoleman@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.4-1
- merge and ruby-1.8 prep (mmcgrath@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- Fix documentation links (aboone@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Adding Flex Monitoring and Scaling video for Chinese viewers
  (aboone@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)
- Adding China-hosted Flex - Deploying Seam video (BZ 773191)
  (aboone@redhat.com)
