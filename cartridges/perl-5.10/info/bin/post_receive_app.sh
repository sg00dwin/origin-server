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

if [ -z "$JENKINS_ENABLED" ] || [ -n "$BUILD_NUMBER" ]
then
    # Run when jenkins is not being used or run when inside a build
    export PERL5LIB="${OPENSHIFT_REPO_DIR}libs:~/${OPENSHIFT_APP_NAME}/perl5lib"
    
    if [ -f ${OPENSHIFT_REPO_DIR}deplist.txt ]
    then
        for f in $( (find ${OPENSHIFT_REPO_DIR} -type f | grep -e "\.pm$\|.pl$" | xargs /usr/lib/rpm/perl.req | awk '{ print $1 }' | sed 's/^perl(\(.*\))$/\1/'; cat ${OPENSHIFT_REPO_DIR}deplist.txt ) | sort | uniq)
        do
            cpanm -L ~/${OPENSHIFT_APP_NAME}/perl5lib "$f"
        done
    fi
else
    set -e
    echo "Executing Jenkins build."
    echo
    echo "NOTE: If build fails, deployment will halt.  Last previous 'good' build will continue to run."
    echo
    echo "You can track your build at http://${JENKINS_URL}/job/${OPENSHIFT_APP_NAME}-build"
    echo
    jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build 
    set +e
fi

if [ -z "$BUILD_NUMBER" ]
then
    user_build.sh
fi

if [ -z "$JENKINS_ENABLED" ]
then
  # Start the app
  start_app.sh
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi