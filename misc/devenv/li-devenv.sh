#!/bin/bash

echo "nameserver 4.2.2.2" >> /etc/resolv.conf

#rpm -Uhv http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
#rpm -Uhv http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
baseurl=http://mirror1.stg.rhcloud.com/mirror/epel/6/\$basearch/
        http://mirror2.stg.rhcloud.com/mirror/epel/6/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0

[epel-testing]
name=Extra Packages for Enterprise Linux 6 - Testing - \$basearch
baseurl=http://mirror1.stg.rhcloud.com/mirror/epel/testing/6/\$basearch/
        http://mirror2.stg.rhcloud.com/mirror/epel/testing/6/\$basearch/
failovermethod=priority
enabled=0
gpgcheck=0

EOF
#sed -i s/sslverify=1/sslverify=0/g /etc/yum.repos.d/rh-cloud.repo

cat > /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.stg.rhcloud.com/libra/libra-rhel-6.2-${1-candidate}/\$basearch/
        https://mirror2.stg.rhcloud.com/libra/libra-rhel-6.2-${1-candidate}/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[li-source]
name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.stg.rhcloud.com/libra/libra-rhel-6.2-${1-candidate}/source/SRPMS/
        https://mirror2.stg.rhcloud.com/libra/libra-rhel-6.2-${1-candidate}/source/SRPMS/
failovermethod=priority
enabled=0
gpgkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[qpid]
name=Qpid repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.stg.rhcloud.com/libra/qpid/\$basearch/Packages/
        https://mirror2.stg.rhcloud.com/libra/qpid/\$basearch/Packages/
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=https://mirror1.stg.rhcloud.com/libra/li-signing.asc
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[passenger]
name=Passenger repo for Enterprise Linux 6
baseurl=https://mirror1.stg.rhcloud.com/libra/passenger
        https://mirror2.stg.rhcloud.com/libra/passenger
failovermethod=priority
enabled=1
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[rhui-us-east-1-rhel-server-releases-i386]
name=Red Hat Enterprise Linux Server 6 -i386 (RPMs)
mirrorlist=https://rhui2-cds01.us-east-1.aws.ce.redhat.com/pulp/mirror/content/dist/rhel/rhui/server/6/\$releasever/i386/os
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-auxiliary
sslverify=1
sslclientkey=/etc/pki/entitlement/content-rhel6-key.pem
sslclientcert=/etc/pki/entitlement/product/content-rhel6.crt
sslcacert=/etc/pki/entitlement/cdn.redhat.com-chain.crt
includepkgs=java-1.6.0-openjdk*

[ruby193]
name=Ruby193 Software Collection for RHEL6 - $basearch
baseurl=https://mirror1.stg.rhcloud.com/libra/ruby193-rhel-6-${1-candidate}/\$basearch/
        https://mirror2.stg.rhcloud.com/libra/ruby193-rhel-6-${1-candidate}/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[rhel63]
name= Red Hat Enterprise Linux Server 6.3 - $basearch
baseurl=https://mirror1.stg.rhcloud.com/libra/rhel6.3/\$basearch/
        https://mirror2.stg.rhcloud.com/libra/rhel6.3/\$basearch/
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.stg.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem


EOF

# Install the 32 bit java before anything else
yum update -y --exclude='rhc*' --exclude='mcollective*'
yum -y install java-1.6.0-openjdk.i686 java-1.6.0-openjdk-devel.i686


function install_requires {
  spec_file=$2
  requires=""
  output=$2
  IFS_BAK=$IFS
IFS="
"
  for s in $(grep -e "^$1:" $spec_file)
  do
    s=`echo ${s//$1:/}`
    s=`echo ${s// /}`
    s=`echo ${s//(/-}`
    s=`echo ${s//)/}`
    s=`echo ${s//>=*/}`
    s=`echo ${s//=/-}`
    s=`echo ${s//,/ }`
    if ! [[ $s =~ "%{" ]]
    then
      if [ -n "$3" ]
      then
        if ! `contains_value "$s" "${@:3}"`
        then
          requires+=" $s"
        fi
      else
        requires+=" $s"
      fi
    fi
  done
  IFS=$IFS_BAK
  if [ -n "$requires" ]
  then
    yum install -y $requires
  fi
}

function find_and_build_specs {
  pushd /root/li-working > /dev/null
    ignore_packages=(`build/devenv print_ignore_packages`)
  popd > /dev/null
  for x in $(find -name *.spec)
  do
    package_name=`get_package_name $x`
    if ! `contains_value "$package_name" "${ignore_packages[@]}"`
    then
      install_requires "BuildRequires" "$x"
      dir=$(dirname $x)
      pushd $dir > /dev/null
        tito build --test --rpm
      popd > /dev/null
    fi
  done
}

function contains_value { 
  for v in "${@:2}"
  do 
    [[ "$v" = "$1" ]] && break
  done
}

function get_package_name {
  name_grep=`grep -e "^Name:" $1`
  name_grep_array=($name_grep)
  package_name=${name_grep_array[1]}
  if [[ $package_name =~ "%{gemname}" ]]
  then
    gemname_grep=`grep -e "%global gemname" $1`
    gemname_grep_array=($gemname_grep)
    gemname=${gemname_grep_array[2]}
    package_name=`echo ${package_name//%\{gemname\}/$gemname}`
  fi
  echo "$package_name"
}

github_repos=( crankcase os-client-tools )
repos=( crankcase os-client-tools li-working )

branch="master"
if [ "$1" == "stage" ]
then
  branch="stage"
fi

rm -rf /root/li-working

if [[ "$2" == "--install_from_source" ]] || [[ "$2" == "--install_required_packages" ]]
then
  git clone git://git1.ops.rhcloud.com/li.git/ /root/li-working

  for repo_name in "${github_repos[@]}"
  do
    rm -rf /root/$repo_name
    git clone git@github.com:openshift/$repo_name.git /root/$repo_name
  done
elif [[ "$2" == "--install_from_local_source" ]]
then
  git clone /root/li /root/li-working
fi

if [[ "$2" == "--install_from_source" ]] || [[ "$2" == "--install_from_local_source" ]]
then

  mkdir -p /tmp/tito

  for repo_name in "${repos[@]}"
  do
    if [ -d /root/$repo_name ]
    then
      pushd /root/$repo_name > /dev/null
        git checkout $branch
        find_and_build_specs
      popd > /dev/null
    fi
  done

  yum -y install createrepo
  mkdir /root/li-local/

  cat > /etc/yum.repos.d/local.repo <<EOF
[li-local]
name=li-local
baseurl=file:///root/li-local/
enabled=0
gpgcheck=0
EOF

  cp /tmp/tito/x86_64/*.rpm /root/li-local/
  cp /tmp/tito/noarch/*.rpm /root/li-local/
  createrepo /root/li-local/

  yum -y install rhc-devenv --enablerepo=li-local
  
  pushd /root/li-working > /dev/null
    build/devenv write_sync_history
  popd > /dev/null
elif [[ "$2" == "--install_required_packages" ]]
then
  pushd /root/li-working > /dev/null
    git checkout $branch
    packages=(`build/devenv print_packages`)
    ignore_packages=(`build/devenv print_ignore_packages`)
  popd > /dev/null
  for repo_name in "${repos[@]}"
  do
    pushd /root/$repo_name > /dev/null
      git checkout $branch
      for x in $(find -name *.spec)
      do
        package_name=`get_package_name $x`
        if ! `contains_value "$package_name" "${ignore_packages[@]}"`
	    then
	      install_requires "BuildRequires" "$x"
	      install_requires "Requires" "$x" "${packages[@]}"
	    fi
	  done
	popd > /dev/null
  done
elif [ "$2" == "--install_build_prereqs" ]
then
  yum -y install git tito ruby rubygems rubygem-thor rubygem-parseconfig rubygem-json rubygem-aws-sdk
else
  yum -y install rhc-devenv
fi

if [[ "$2" == "--install_from_source" ]] || [[ "$2" == "--install_from_local_source" ]] || [[ "$2" == "--install_required_packages" ]]
then
  rm -rf /tmp/tito
  for repo_name in "${repos[@]}"
  do
    rm -rf /root/$repo_name
  done
fi
