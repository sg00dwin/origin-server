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

function print_help {
    echo "Usage: update-ddns.sh -h short_hostname -d domain -i ip.address [-r resolver.ip ]"
    exit 1
}

resolver='209.132.178.9'
secret="hmac-md5:dhcpupdate:fzAvGcKPZWiFgmF8qmNUaA=="

while getopts 'h:d:i:r:' OPTION
do
    case $OPTION in
        h) host=$OPTARG
        ;;
        d) domain=$OPTARG
        ;;
        i) ip=$OPTARG
        ;;
        r) resolver=$OPTARG
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$host" ] || [ -z "$domain" ] || [ -z "$ip" ] || [ -z "$resolver" ] )
then
    print_help
fi

cat << EOF | nsupdate -d -v -y "$secret"
server $resolver
zone $domain
update delete $host.$domain
send
EOF
