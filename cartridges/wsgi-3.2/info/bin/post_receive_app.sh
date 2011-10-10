#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -f ~/.env/OPENSHIFT_CI_TYPE ]
then
    JENKINS_ENABLED=true
else
    redeploy_repo_dir.sh
fi

if [ -z "$JENKINS_ENABLED" ] || [ -n "$BUILD_NUMBER" ]
then
    # Run when jenkins is not being used or run when inside a build
    if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
    then
        echo ".openshift/markers/force_clean_build found!  Recreating virtenv" 1>&2
        rm -rf "${OPENSHIFT_APP_DIR}"/virtenv/*
    fi

    if [ -f ${OPENSHIFT_REPO_DIR}setup.py ]
    then
        echo "setup.py found.  Setting up virtualenv"
        cd ~/${OPENSHIFT_APP_NAME}/virtenv
        virtualenv ~/${OPENSHIFT_APP_NAME}/virtenv
        . ./bin/activate
        python ${OPENSHIFT_REPO_DIR}setup.py develop
        virtualenv --relocatable ~/${OPENSHIFT_APP_NAME}/virtenv
    fi
    
    # Run build
    user_build.sh
else
    set -e
    echo "Executing Jenkins build."
    echo
    echo "NOTE: If build fails, deployment will halt.  Last previous 'good' build will continue to run."
    echo
    echo "You can track your build at ${JENKINS_URL}job/${OPENSHIFT_APP_NAME}-build"
    echo
    jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build 
    set +e
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
