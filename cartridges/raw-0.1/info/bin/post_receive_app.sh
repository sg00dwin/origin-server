#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

JENKINS_ENABLED=false
if [ -f ~/.env/OPENSHIFT_CI_TYPE ]
then
    JENKINS_ENABLED=true
else
    redeploy_repo_dir.sh
fi

if [ -n "$JENKINS_ENABLED" ]
then
    set -e
    jenkins_build.sh
    set +e
else
    # Run build
    user_build.sh
fi

if [ -z "$JENKINS_ENABLED" ] && [ -z "$BUILD_NUMBER" ]
then
    deploy.sh
    # Start the app
    start_app.sh
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi