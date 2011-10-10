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
    echo "Executing Jenkins build."
    echo
    echo "NOTE: If build fails, deployment will halt.  Last previous 'good' build will continue to run."
    echo
    echo "You can track your build at http://${JENKINS_URL}/job/${OPENSHIFT_APP_NAME}-build"
    echo
    jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build 
    set +e
fi

if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found!  Recreating pear libs" 1>&2
    rm -rf "${OPENSHIFT_APP_DIR}"/phplib/pear/*
    mkdir -p "${OPENSHIFT_APP_DIR}"/phplib/pear/{docs,ext,php,cache,cfg,data,download,temp,tests,www}
    pear -c ~/.pearrc config-set php_ini "${OPENSHIFT_APP_DIR}/conf/php.ini"
fi

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

if [ -z "$BUILD_NUMBER" ]
then
    user_build.sh
fi

if [ -z "$JENKINS_ENABLED" ] && [ -z "$BUILD_NUMBER" ]
then
    # Start the app
    start_app.sh
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi
