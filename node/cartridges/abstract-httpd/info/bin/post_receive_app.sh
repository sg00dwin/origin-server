#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -f ~/.env/OPENSHIFT_CI_TYPE ]
then
    set -e
    jenkins_build.sh
    set +e
else
    if [ -z "$BUILD_NUMBER" ]
    then
        pre_deploy.sh
    fi
    build.sh
    if [ -z "$BUILD_NUMBER" ]
    then
        deploy.sh
        start_app.sh
        post_deploy.sh
    fi
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi