#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# pre-receive
~/git/${OPENSHIFT_APP_NAME}.git/hooks/pre-receive 1>&2

# Run pre-dump dumps
for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_DUMP$/) print ENVIRON[a] }'`
do
    echo "Running extra added: $(/bin/basename $cmd)" 1>&2
    $cmd
done

# Run tar, saving to stdout
echo "Creating and sending tar.gz" 1>&2
/bin/tar --ignore-failed-read -chzf - -C ~ \
        --exclude=./.restore \
        --exclude=./.tmp \
        --exclude=./.ssh \
        --exclude=./$OPENSHIFT_APP_NAME/%s_ctl.sh \
        --exclude=./$OPENSHIFT_APP_NAME/conf.d/libra.conf \
        --exclude=./$OPENSHIFT_APP_NAME/modules \
        --exclude=./$OPENSHIFT_APP_NAME/run/httpd.pid .

# post-receive
GIT_DIR=~/git/${OPENSHIFT_APP_NAME}.git/ ~/git/${OPENSHIFT_APP_NAME}.git/hooks/post-receive 1>&2
