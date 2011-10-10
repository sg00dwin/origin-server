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
elif [ -z "$BUILD_NUMBER" ]
then
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


if [ -z "$JENKINS_ENABLED" ]
then
    # Run build
    user_build.sh
fi

if [ -z "$JENKINS_ENABLED" ] && [ -z "$BUILD_NUMBER" ]
then
    deploy.sh
    # Start the app
    start_app.sh
    post_deploy.sh
fi

if [ -z "$BUILD_NUMBER" ]
then
    # Not running inside a build
    nurture_app_push.sh $libra_server
fi
