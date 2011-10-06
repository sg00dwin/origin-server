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
fi

redeploy_repo_dir.sh

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
fi

if $JENKINS_ENABLED
then
  jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build 
fi

# Run build
user_build.sh

if $JENKINS_ENABLED
then
  restart_app.sh
else
  # Start the app
  start_app.sh
fi

nurture_app_push.sh $libra_server
