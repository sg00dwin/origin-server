#!/bin/bash

#
# Create virtualhost definition for apache
#
# node_ssl_template.conf gets copied in unaltered and should contain
# all of the configuration bits required for ssl to work including key location
#
function print_help {
    echo "Usage: $0 app-name namespace uuid IP"

    echo "$0 $@" | logger -p local0.notice -t openshift_origin_metrics_deploy_httpd_proxy
    exit 1
}

[ $# -eq 4 ] || print_help


application="$1"
namespace=`basename $2`
uuid=$3
IP=$4

oo-frontend-connect \
    --with-container-uuid "$uuid" \
    --with-container-name "$application" \
    --with-namespace "$namespace" \
    --path "/metrics" --target "$IP:8080/metrics"
