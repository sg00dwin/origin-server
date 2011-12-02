#!/bin/bash

#
# Create virtualhost definition for apache
#
# node_ssl_template.conf gets copied in unaltered and should contain
# all of the configuration bits required for ssl to work including key location
#
function print_help {
    echo "Usage: $0 app-name namespace uuid IP"

    echo "$0 $@" | logger -p local0.notice -t libra_deploy_httpd_proxy
    exit 1
}

[ $# -eq 4 ] || print_help


application="$1"
namespace=`basename $2`
uuid=$3
IP=$4

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

load_node_conf

cat <<EOF > "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}/rockmongo-1.1.conf"
ProxyPass /rockmongo http://$IP:8080/rockmongo
ProxyPassReverse /rockmongo http://$IP:8080/rockmongo

EOF
