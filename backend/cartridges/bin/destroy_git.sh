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

# delete local git repository for libra

# Exit on any errors
set -e

function print_help {
    echo "Usage: $0"
    echo "Destroys a local git repo"
    echo
    echo "  -c customer_id"
    echo "  -a application_name"
    echo "  -d (optional: debug)"
    exit 1
}

if [ -f './libra.sh' ]
then
    source ./libra.sh
else
    source /usr/local/bin/libra/libra.sh
fi

while getopts 'c:a:d' OPTION
do
    case $OPTION in
        c) customer_id=$OPTARG
        ;;
        a) application=$OPTARG
        ;;
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$customer_id" ] || [ -z "$application" ] )
then
    print_help
fi
CUSTOMER_HOME="${LIBRA_BASE}/${customer_id}"

echo $CUSTOMER_HOME
if [ ! -d $CUSTOMER_HOME ]; then echo "${customer_id} not found!  Please create." 1>&2; exit 2; fi

GIT_DIR=$CUSTOMER_HOME/git/$application.git
rm -rf $GIT_DIR
