#!/bin/bash

#
# Create virtualhost definition for apache
#
# node_ssl_template.conf gets copied in unaltered and should contain
# all of the configuration bits required for ssl to work including key location
#
function print_help {
    echo "Usage: $0 app-name namespace uuid IP"

    echo "$0 $@" | logger -p local0.notice -t stickshift_deploy_httpd_proxy
    exit 1
}

[ $# -eq 4 ] || print_help


application="$1"
namespace=`basename $2`
uuid=$3
IP=$4

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

cat <<EOF > "${STICKSHIFT_HTTP_CONF_DIR}/${uuid}_${namespace}_${application}/zend_5_6_lighttpd.conf"
ProxyPass /ZendServer http://$IP:16081/ZendServer status=I
ProxyPassReverse /ZendServer http://$IP:16081/ZendServer

EOF
