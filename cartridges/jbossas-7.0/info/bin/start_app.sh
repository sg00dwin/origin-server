#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

echo -n "Starting application..."
if [ -f ~/${OPENSHIFT_APP_NAME}/run/stop_lock ]
then
    echo skipped due to stop_lock
else
    exec 1>&- # close stdout
    ~/${OPENSHIFT_APP_NAME}/${OPENSHIFT_APP_NAME}_ctl.sh start >/dev/null 2>&1
    exec 1>&2 # redirect stdout to stderr
    echo "Done"
fi