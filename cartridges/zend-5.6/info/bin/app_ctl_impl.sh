#!/bin/bash -e

# Expose which cartridge created the ctl script
export CARTRIDGE_TYPE="zend-5.6"

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done
echo $UID
GID=$UID
if [ ! -z $LD_LIBRARY_PATH ];then
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/zend/lib
        export LD_LIBRARY_PATH
fi

ZCE_PREFIX=/usr/local/zend
#export INSTALLATION_UID=0410121306
export ZEND_TMPDIR=/usr/local/zend/tmp
PRODUCT_NAME="Zend Server"
PRODUCT_VERSION=5.6.0
WEB_USER=$(whoami)
APACHE_PID_FILE=run/httpd.pid
#APACHE_HTDOCS=/var/www/html
#DIST=pe

/usr/local/zend/bin/zdd.sh $1
/usr/local/zend/bin/monitor-node.sh $1
#starts apache
httpd_ctl.sh $1
/usr/local/zend/bin/scd.sh $1
/usr/local/zend/bin/jqd.sh $1
/usr/local/zend/bin/lighttpdctl.sh $1


