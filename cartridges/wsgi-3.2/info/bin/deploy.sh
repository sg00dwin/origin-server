#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Run build
#virtualenv --relocatable ${OPENSHIFT_APP_DIR}virtenv
#. ./bin/activate

if [ -d ${OPENSHIFT_APP_DIR}virtenv ]
then 
    pushd ${OPENSHIFT_APP_DIR}virtenv > /dev/null
    . ./bin/activate
    popd > /dev/null
fi

user_deploy.sh