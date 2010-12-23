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

# Destroy http libra instance

# Exit on any errors
set -e

function print_help {
    echo "Usage: $0"
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

CUSTOMER_HOME="$LIBRA_BASE/$customer_id/"
APP_DIR="$CUSTOMER_HOME/httpd/$application"

#
# delete git app repo
#

/usr/local/bin/libra/destroy_git.sh -c $customer_id -a $application

# Stop running application
"$APP_DIR/${application}_ctl.sh" stop

#
# Delete Application Dir
#

rm -rf $APP_DIR

#
# Find an open localhost IP
# 

IP=$(take_open_ip $customer_id $application "httpd" 8080)

#
# Create simple customer specific data
#

rm -f "$APP_DIR/conf.d/libra.conf"

#
# Remove virtualhost definition for apache
#

rm -f "/etc/httpd/conf.d/${customer_id}_${application}.conf"

/sbin/service httpd configtest 2> /dev/null && /sbin/service httpd graceful

#
# Remove DDNS
#

/usr/local/bin/libra/remove-ddns.sh -h ${application}.${customer_id} -d libra.mmcgrath.net -i $(/usr/bin/facter ipaddress)
