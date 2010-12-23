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

# This file provides common base libraries for creating and managing various
# libra projects.

LIBRA_BASE=/var/lib/libra/
LIBRA_CONF=/etc/libra
mkdir -p $LIBRA_BASE $LIBRA_CONF

function quit {
    echo $1 2>&1
    echo $1 | /usr/bin/logger -p local0.notice -t libra_http_create
    exit
}

function log {
    echo $1 2>&1
    echo $1 | /usr/bin/logger -p local0.notice -t libra_http_create
}


function create_customerspace {
    if ! [ $# -eq 2 ]
    then
        echo "Usage: $0 customer_id $email"
        exit 1
    fi
    CUSTOMER_HOME="$LIBRA_BASE/$customer_id/"

    customer_id="$1"

    mkdir -p "$CUSTOMER_HOME/etc/"
    cat <<EOF > "$CUSTOMER_HOME/etc/customer_info"
CUSTOMER_ID="$customer_id"
EMAIL="$email"
EOF

    chmod 0700 -R "$CUSTOMER_HOME"
    grep -q "$customer_id" /etc/passwd || useradd -d "$CUSTOMER_HOME" -M -s /bin/bash "$customer_id"
    chown "$customer_id" -R "$CUSTOMER_HOME"
}

function find_open_ip {
    # Find an open 127.0.x.x address to host application
    [ -f $LIBRA_CONF/ip_db ] || echo "customer_id,application_name,service_type,port" >> $LIBRA_CONF/ip_db
    for i in `seq 0 255`
    do
        for j in `seq 2 255`
        do
            if ! $(grep -q 127.0.$i.$j $LIBRA_CONF/ip_db)
            then
                echo 127.0.$i.$j
                exit
            fi
        done
    done
}

function take_open_ip {
    # Writes a new IP to the ip database in $LIBRA_CONF/ip_db
    # Example: take_open_ip mmcgrath phpmyadmin httpd
    if ! [ $# -eq 4 ]
    then
        echo "Usage: $0 customer_id application_name service_type port"
        exit 1
    fi
    customer_id=$1
    application_name=$2
    service_type=$3
    port=$4

    # if customer, app, service already exists, re-use IP
    if $( grep -q "$customer_id,$application_name,$service_type" $LIBRA_CONF/ip_db )
    then
        echo $(awk -F, "/$customer_id,$application_name,$service_type/"'{ print $1 }' $LIBRA_CONF/ip_db | head -n1)
    else
        IP=$(find_open_ip)
        echo "$IP,$customer_id,$application_name,$service_type,$port" >> $LIBRA_CONF/ip_db
        echo $IP
    fi
}
