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

# Creates a per customer httpd instance

# Exit on any errors
set -e

function print_help {
    echo "Usage: $0"
    echo "  -c customer_id"
    echo "  -a application_name"
    echo "  -d (optional: debug)"

    echo "$0 $@" | logger -p local0.notice -t libra_http_create
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
# Create git app repo
#

/usr/local/bin/libra/create_git.sh -c $customer_id -a $application

cat <<EOF > $CUSTOMER_HOME/git/$application.git/hooks/post-receive
rm -rf /var/lib/libra/$customer_id/httpd/test/html/*
git archive --format=tar HEAD | (cd $APP_DIR/html && tar xf -)
# Reload httpd here maybe?
EOF
chmod 0750 $CUSTOMER_HOME/git/$application.git/hooks/post-receive

#
# Create http base for application, every app gets its own apache instance
#

if [ -d "$APP_DIR" ]
then
    echo "ERROR: $application already exists.  Please destroy to re-create or pick a new app name"
    exit 5
fi

mkdir -p "$APP_DIR"
pushd "$APP_DIR" > /dev/null
mkdir conf conf.d logs run html
ln -s /usr/lib64/httpd/modules modules
popd > /dev/null

#
# Find an open localhost IP
# 


IP=$(take_open_ip $customer_id $application "httpd" 8080)


#
# Create simple customer specific data
#

cat <<EOF > "$APP_DIR/conf.d/libra.conf"
ServerRoot "$APP_DIR"
DocumentRoot "$APP_DIR/html"
Listen $IP:8080
User $customer_id
Group $customer_id
EOF

#
# Create simple application start / stop script
#

cat <<EOF > "$APP_DIR/${application}_ctl.sh"
#/bin/bash
if ! [ \$# -eq 1 ]
then
    echo "Usage: \$0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi
/usr/sbin/httpd -C 'Include $APP_DIR/conf.d/*.conf' -f /etc/libra/httpd.conf -k \$1
EOF

chmod +x "$APP_DIR/${application}_ctl.sh"

chown $customer_id.$customer_id -R $APP_DIR
$APP_DIR/${application}_ctl.sh start

#
# Create virtualhost definition for apache
#

cat <<EOF > "/etc/httpd/conf.d/${customer_id}_${application}.conf"
<VirtualHost *:80>
  ServerName ${application}.${customer_id}.libra.mmcgrath.net
  ServerAdmin mmcgrath@redhat.com
  DocumentRoot /var/www/html
  ErrorLog logs/$customer_id.libra.mmcgrath.net-error_log
  TransferLog logs/$customer_id.libra.mmcgrath.net-access_log

  ProxyPass / http://$IP:8080/
  ProxyPassReverse / http://$IP:8080/
</VirtualHost>
EOF

/sbin/service httpd configtest 2> /dev/null && /sbin/service httpd graceful

/usr/local/bin/libra/update-ddns.sh -h ${application}.${customer_id} -d libra.mmcgrath.net -i $(/usr/bin/facter ipaddress)
