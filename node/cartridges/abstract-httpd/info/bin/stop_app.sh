#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

echo "Stopping application..."
~/${OPENSHIFT_APP_NAME}/${OPENSHIFT_APP_NAME}_ctl.sh stop
echo "Done"