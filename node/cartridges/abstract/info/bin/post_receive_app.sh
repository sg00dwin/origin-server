#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ "$OPENSHIFT_CI_TYPE" = "jenkins-1.4" ] && [ -n "$JENKINS_URL" ]
then
    set -e
    jenkins_build.sh
    set +e
else
    if [ "$OPENSHIFT_CI_TYPE" = "jenkins-1.4" ]
    then
        echo "!!!!!!!!"
        echo "Jenkins client installed but a Jenkins server does not exist!"
        echo "You can remove the jenkins client with rhc app cartridge remove -a $OPENSHIFT_APP_NAME -c jenkins-client-1.4"
        echo "Continuing with local build/deployment."
        echo "!!!!!!!!"
    fi

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