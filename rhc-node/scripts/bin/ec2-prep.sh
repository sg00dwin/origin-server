#!/bin/bash

# Copyright © 2010 Mike McGrath All rights reserved
# Copyright © 2010 Red Hat, Inc. All rights reserved

# This copyrighted material is made available to anyone wishing to use, modify,
# copy, or redistribute it subject to the terms and conditions of the GNU
# General Public License v.2.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY expressed or implied, including the
# implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.  You should have
# received a copy of the GNU General Public License along with this program;
# if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301, USA. Any Red Hat trademarks that are
# incorporated in the source code or documentation are not subject to the GNU
# General Public License and may only be used or replicated with the express
# permission of Red Hat, Inc.

# This script will log in to an ec2 host and install epel, git and puppet

# This key belongs to mmcgrath and fedora
ACTIVATION_KEY='28fbe0785acc9f1bc8ccc98f216d26ab'

function print_help {
    echo "Usage: $0 remote.host.name"
    exit 1
}

if ! [ $# -eq 1 ]
then
    print_help
fi

remotehost=$1

ssh root@$remotehost "set -e
rpm -Uhv http://download.fedora.redhat.com/pub/epel/beta/6/x86_64/epel-release-6-5.noarch.rpm
rpm -e rh-amazon-rhui-client
rpm -Uhv https://mirror1.ops.rhcloud.com/libra/li/rhel/6/x86_64/rhel6-and-optional-0.1-1.noarch.rpm
yum -y update
yum -y install puppet git
mkdir -p /var/lib/puppet/git/
GIT_DIR=/var/lib/puppet/git git init
echo 'git archive --format=tar HEAD | (cd /etc/puppet && tar xf -)
puppet --modulepath=/etc/puppet/modules /etc/puppet/manifests/site.pp -v' > /var/lib/puppet/git/hooks/post-receive
chmod +x /var/lib/puppet/git/hooks/post-receive
reboot
"
