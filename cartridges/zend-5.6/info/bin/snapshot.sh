#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Run pre-dump dumps
for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_DUMP$/) print ENVIRON[a] }'`
do
    echo "Running extra dump: $(/bin/basename $cmd)" 1>&2
    $cmd
done

# stop
stop_app.sh 1>&2

# Run tar, saving to stdout
cd ~
cd ..
echo "Creating and sending tar.gz" 1>&2

cart_type=$(basename $(dirname $OPENSHIFT_GEAR_CTL_SCRIPT))
/bin/tar --ignore-failed-read -czf - \
        --exclude=./$OPENSHIFT_GEAR_UUID/.tmp \
        --exclude=./$OPENSHIFT_GEAR_UUID/.ssh \
        --exclude=./$OPENSHIFT_GEAR_UUID/.sandbox \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/${OPENSHIFT_GEAR_NAME}_ctl.sh \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/conf.d/*.conf \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/run/httpd.pid \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/bin \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/doc \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/etc/conf.d/debugger.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/etc/conf.d/ZendGlobalDirectives.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/include \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/lib \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/share \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/tmp/* \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/lighttpd/etc/lighttpd.conf \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/application/*.php \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/application/data/zend-server.ini \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/application/CE \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/application/PE \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/application/layouts \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/html \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/library \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/lighttpd/tmp/* \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/UserServer \
        --exclude=./$OPENSHIFT_GEAR_UUID/$cart_type/gui/utils \
        --exclude=./$OPENSHIFT_GEAR_UUID/haproxy-\*/run/stats \
        --exclude=./$OPENSHIFT_GEAR_UUID/app-root/runtime/.state \
        --exclude=./$OPENSHIFT_GEAR_UUID/app-root/data/.bash_history \
        ./$OPENSHIFT_GEAR_UUID

# Cleanup
for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_DUMP_CLEANUP$/) print ENVIRON[a] }'`
do
    echo "Running extra cleanup: $(/bin/basename $cmd)" 1>&2
    $cmd
done


# start_app
start_app.sh 1>&2
