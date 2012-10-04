#!/bin/bash

# Import Environment Variables
for f in ~/.env/*; do . $f; done
cartridge_type="zend-5.6"
cartridge_dir=$OPENSHIFT_HOMEDIR/$cartridge_type

source /etc/stickshift/stickshift-node.conf
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

# Run pre-dump dumps
for db in $(get_attached_databases)
do
    dump_cmd=${CARTRIDGE_BASE_PATH}/$db/info/bin/dump.sh
    echo "Running extra dump for $db" 1>&2
    $dump_cmd
done

# stop
set -x
stop_app.sh 1>&2
set +x

# Run tar, saving to stdout
cd ~
cd ..
echo "Creating and sending tar.gz" 1>&2

/bin/tar --ignore-failed-read -czf - \
        --exclude=./$OPENSHIFT_GEAR_UUID/.tmp \
        --exclude=./$OPENSHIFT_GEAR_UUID/.ssh \
        --exclude=./$OPENSHIFT_GEAR_UUID/.sandbox \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/app_ctl.sh \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/conf.d/*.conf \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/run/httpd.pid \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/bin \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/doc \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/etc/conf.d/debugger.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/etc/conf.d/ZendGlobalDirectives.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/include \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/lib \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/share \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/tmp/* \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/lighttpd/etc/lighttpd.conf \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/application/*.php \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/application/data/zend-server.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/application/CE \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/application/PE \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/application/layouts \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/html \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/library \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/lighttpd/tmp/* \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/UserServer \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cartridge_type/gui/utils \
        --exclude=./$OPENSHIFT_GEAR_UUID/haproxy-\*/run/stats \
        --exclude=./$OPENSHIFT_GEAR_UUID/app-root/runtime/.state \
        --exclude=./$OPENSHIFT_GEAR_UUID/app-root/data/.bash_history \
        ./$OPENSHIFT_GEAR_UUID

# Cleanup
for db in $(get_attached_databases)
do
    cleanup_cmd=${CARTRIDGE_BASE_PATH}/db/info/bin/cleanup.sh
    echo "Running extra cleanup for $db" 1>&2
    $cleanup_cmd
done

# start_app
start_app.sh 1>&2
