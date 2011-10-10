#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Run build
#virtualenv --relocatable ~/${OPENSHIFT_APP_NAME}/virtenv
#. ./bin/activate
cd ~/${OPENSHIFT_APP_NAME}/virtenv
. ./bin/activate

user_deploy.sh