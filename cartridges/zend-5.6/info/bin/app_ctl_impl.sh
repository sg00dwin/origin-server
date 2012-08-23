#!/bin/bash -e

# Expose which cartridge created the ctl script
export CARTRIDGE_TYPE="zend-5.6"

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -f /etc/zce.rc ];then
    . /etc/zce.rc
else
    echo "/etc/zce.rc doesn't exist!"
    exit 1;
fi


[ "$1" == "reload" ] && shift && eval set -- "restart $@"

/usr/local/zend/bin/zdd.sh $1
/usr/local/zend/bin/monitor-node.sh $1
#starts apache
httpd_ctl.sh $1
#/usr/local/zend/bin/scd.sh $1
/usr/local/zend/bin/jqd.sh $1
/usr/local/zend/bin/lighttpdctl.sh $1


