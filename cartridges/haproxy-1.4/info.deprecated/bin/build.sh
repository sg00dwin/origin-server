#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found but disabled for haproxy" 1>&2
fi

# Run user build
user_build.sh
