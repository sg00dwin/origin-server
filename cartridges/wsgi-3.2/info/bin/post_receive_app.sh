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
fi

if [ -z "$JENKINS_ENABLED" ]
then
    # Run only if jenkins is not enabled
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

fi

if [ -n "$JENKINS_ENABLED" ]
then
    set -e
    echo "Executing Jenkins build."
    echo
    echo "NOTE: If build fails, deployment will halt.  Last previous 'good' build will continue to run."
    echo
    echo "You can track your build at http://jenktest-mmcgrath000.dev.rhcloud.com/job/${OPENSHIFT_APP_NAME}-build"
    echo
    jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build 
    set +e
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not inside a a build
    # Run build
    #virtualenv --relocatable ~/${OPENSHIFT_APP_NAME}/virtenv
    #. ./bin/activate
    cd ~/${OPENSHIFT_APP_NAME}/virtenv
    . ./bin/activate
    user_build.sh
fi

if [ -n "$JENKINS_ENABLED" ]
then
  # Start the app
  start_app.sh
else
  restart_app.sh
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi
