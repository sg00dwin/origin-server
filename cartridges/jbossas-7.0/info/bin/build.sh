#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CONFIG_DIR="/usr/libexec/li/cartridges/jbossas-7.0/info/configuration"
if `echo $OPENSHIFT_APP_DNS | grep -q .stg.rhcloud.com` || `echo $OPENSHIFT_APP_DNS | grep -q .dev.rhcloud.com`
then 
	OPENSHIFT_MAVEN_MIRROR="$CONFIG_DIR/settings.stg.xml"
else
	OPENSHIFT_MAVEN_MIRROR="$CONFIG_DIR/settings.prod.xml"
fi

if [ -z "$BUILD_NUMBER" ]
then
    SKIP_MAVEN_BUILD=false
    if git show master:.openshift/markers/skip_maven_build > /dev/null 2>&1
    then
        SKIP_MAVEN_BUILD=true
    fi
    
    if [ -f ${OPENSHIFT_REPO_DIR}pom.xml ] && ! $SKIP_MAVEN_BUILD
    then
        echo "Found pom.xml... attempting to build with 'mvn -e clean package -Popenshift -DskipTests'" 
        export JAVA_HOME=/etc/alternatives/java_sdk_1.6.0
        export M2_HOME=/etc/alternatives/maven-3.0
        export MAVEN_OPTS="-Xmx208m"
        export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
        pushd ${OPENSHIFT_REPO_DIR} > /dev/null
        if [ -n "$OPENSHIFT_MAVEN_MIRROR" ]
        then
            mvn --global-settings $OPENSHIFT_MAVEN_MIRROR --version
            mvn --global-settings $OPENSHIFT_MAVEN_MIRROR clean package -Popenshift -DskipTests
        else
            mvn --version
            mvn clean package -Popenshift -DskipTests
        fi
        popd > /dev/null
    fi
else
    export OPENSHIFT_MAVEN_MIRROR
fi

user_build.sh
