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

# Creates a local git repository for libra to pull code from

# Exit on any errors
set -e

function print_help {
    echo "Usage: $0"
    echo "  -c customer_id"
    echo "  -e email"
    echo "  -s ssh_pub_key"
    echo "  -d (optional: debug)"
    exit 1
}

if [ -f './libra.sh' ]
then
    source ./libra.sh
else
    source /usr/local/bin/libra/libra.sh
fi

while getopts 'c:e:s:d' OPTION
do
    case $OPTION in
        c) customer_id=$OPTARG
        ;;
        e) email=$OPTARG
        ;;
        s) ssh_key=$OPTARG
        ;;
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$customer_id" ] || [ -z "$email" ] || [ -z "$ssh_key" ] )
then
    print_help
fi

create_customerspace "$customer_id" "$email"

mkdir -p "$CUSTOMER_HOME/.ssh"
chmod 0700 "$CUSTOMER_HOME/.ssh"
cat <<EOF > "$CUSTOMER_HOME/.ssh/authorized_keys"
command="/usr/local/bin/trap-user",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa $ssh_key Libra-$customer_id-$email
EOF
chmod 0600 "$CUSTOMER_HOME/.ssh/authorized_keys"
chown "$customer_id"."$customer_id" -R "$CUSTOMER_HOME"
/sbin/restorecon -R "$CUSTOMER_HOME/.ssh/"
