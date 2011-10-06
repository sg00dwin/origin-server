#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

JENKINS_ENABLED=false
if [ -f ~/.env/JENKINS_URL ]
then
  JENKINS_ENABLED=true
fi

redeploy_repo_dir.sh

if [ -f ~/${OPENSHIFT_APP_NAME}/repo/deplist.txt ]
then
    for f in $(cat ~/${OPENSHIFT_APP_NAME}/repo/deplist.txt)
    do
        echo "Checking pear: $f"
        echo
        if pear list "$f" > /dev/null
        then
            pear upgrade "$f"
        else
            pear install --alldeps "$f"
        fi
    done
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
