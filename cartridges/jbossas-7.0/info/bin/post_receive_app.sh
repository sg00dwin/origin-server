#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done


SKIP_MAVEN_BUILD=false
if git show master:.openshift/markers/skip_maven_build > /dev/null 2>&1
then
    SKIP_MAVEN_BUILD=true
fi

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
elif [ -z "$BUILD_NUMBER" ]
    if [ -f ${OPENSHIFT_REPO_DIR}pom.xml ] && ! $SKIP_MAVEN_BUILD
    then
        echo "Found pom.xml... attempting to build with 'mvn clean package -Popenshift -DskipTests'" 
        export JAVA_HOME=/etc/alternatives/java_sdk_1.6.0
        export M2_HOME=/etc/alternatives/maven-3.0
        export MAVEN_OPTS="-Xmx208m"
        export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
        pushd ${OPENSHIFT_REPO_DIR} > /dev/null
        mvn --version
        mvn clean package -Popenshift -DskipTests
        popd
    fi
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Create a link for each file in user config to server standalone/config
    if [ -d ${OPENSHIFT_REPO_DIR}.openshift/config ]
    then
      for f in ${OPENSHIFT_REPO_DIR}.openshift/config/*
      do
        target=$(basename $f)
        # Remove any target that is being overwritten
        if [ -e "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target" ]
        then
           echo "Removing existing $target"
           rm -rf "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target"
        fi
        ln -s $f "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/"
      done
    fi
    # Now go through the standalone/configuration and remove any stale links from previous
    # deployments, https://bugzilla.redhat.com/show_bug.cgi?id=734380
    for f in "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration"/*
    do
        target=$(basename $f)
        if [ ! -e $f ]
        then
            echo "Removing obsolete $target"
            rm -rf $f
        fi
    done


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
