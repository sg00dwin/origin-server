#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

echo "Starting application..."
~/${OPENSHIFT_APP_NAME}/${OPENSHIFT_APP_NAME}_ctl.sh start