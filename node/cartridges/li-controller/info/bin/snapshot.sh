#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# stop
stop_app.sh 1>&2

# Run pre-dump dumps
for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_DUMP$/) print ENVIRON[a] }'`
do
    echo "Running extra dump: $(/bin/basename $cmd)" 1>&2
    $cmd
done

# Run tar, saving to stdout
echo "Creating and sending tar.gz" 1>&2
/bin/tar --ignore-failed-read -czf - -C ~ \
        --exclude=./.tmp \
        --exclude=./.ssh \
        --exclude=./$OPENSHIFT_APP_NAME/%s_ctl.sh \
        --exclude=./$OPENSHIFT_APP_NAME/conf.d/libra.conf \
        --exclude=./$OPENSHIFT_APP_NAME/run/httpd.pid .

# Cleanup
for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_DUMP_CLEANUP$/) print ENVIRON[a] }'`
do
    echo "Running extra cleanup: $(/bin/basename $cmd)" 1>&2
    $cmd
done

# start_app
start_app.sh 1>&2
