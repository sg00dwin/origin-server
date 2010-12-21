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

LI_SERVER='li.mmcgrath.libra.mmcgrath.net'

function print_help {
    echo "Usage: $0"
    echo "Create a new libra user."
    echo
    echo "  -u username             Libra Username"
    echo "  -e email                Email address"
    echo "  -d (optional: debug)"
    exit 1
}

while getopts 'u:e:d' OPTION
do
    case $OPTION in
        u) username=$OPTARG
        ;;
        e) email=$OPTARG
        ;;
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$username" ] || [ -z "$email" ] )
then
    print_help
fi

if [ -f ~/.ssh/libra_id_rsa ]
then
echo "Libra key found at ~/.ssh/libra_id_rsa.  Reusing..."
else
echo "Generating libra ssh key to ~/.ssh/libra_id_rsa"
ssh-keygen -t rsa -f ~/.ssh/libra_id_rsa
fi
ssh_key=$(awk '{ print $2 }' ~/.ssh/libra_id_rsa.pub)

TMPDIR=$(mktemp -d --suffix=libra)
curl -s --data-urlencode "username=${username}" --data-urlencode "email=${email}" --data-urlencode "ssh_key=${ssh_key}" "http://$LI_SERVER/create_customer.php" > $TMPDIR/debug.log 2>&1 || quit "Creation failed.  See $TMPDIR/debug.log for more information"
