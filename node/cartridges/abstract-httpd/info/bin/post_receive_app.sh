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
    # Do any cleanup before the next build
    pre_build.sh
    
    # Lay down new code, run internal build steps, then user build
    build.sh
    
    # Deploy new build, run internal deploy steps, then user deploy
    deploy.sh
    
    # Start the app
    start_app.sh
    
    # Run any steps required after startup
    post_deploy.sh
fi

# Not running inside a build
nurture_app_push.sh $libra_server