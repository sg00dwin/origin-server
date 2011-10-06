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

if [ -f '/etc/libra/node.conf' ]
then
    . /etc/libra/node.conf
elif [ -f 'node.conf' ]
then
    . node.conf
else
    echo "node.conf not found.  Cannot continue" 1>&2
    exit 3
fi

rm -rf "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}.conf" "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}"

mkdir "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}"

cat <<EOF > "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}/00000_default.conf"
  ServerName ${application}-${namespace}.${libra_domain}
  ServerAdmin mmcgrath@redhat.com
  DocumentRoot /var/www/html
  DefaultType None
EOF
cat <<EOF > "/etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}.conf"
<VirtualHost *:80>
  RequestHeader append X-Forwarded-Proto "http"

  Include /etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}/*.conf

  RewriteEngine On
  RewriteRule /health /usr/libexec/li/cartridges/jenkins-1.4/info/configuration/health [L]
  ##Alias /health /usr/libexec/li/cartridges/jenkins-1.4/info/configuration/health
  ProxyPass / http://$IP:8080/
  ProxyPassReverse / http://$IP:8080/
</VirtualHost>

<VirtualHost *:443>
  RequestHeader append X-Forwarded-Proto "https"

$(/bin/cat $CART_INFO_DIR/configuration/node_ssl_template.conf)

  Include /etc/httpd/conf.d/libra/${uuid}_${namespace}_${application}/*.conf
  
  RewriteEngine On
  RewriteRule /health /usr/libexec/li/cartridges/jenkins-1.4/info/configuration/health [L]
  ##Alias /health /usr/libexec/li/cartridges/jenkins-1.4/info/configuration/health
  ProxyPass / http://$IP:8080/
  ProxyPassReverse / http://$IP:8080/
</VirtualHost>
EOF
