#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

HERE="/usr/libexec/li/cartridges/jbossas-7.0/info/bin"
if `echo $OPENSHIFT_APP_DNS | grep -q stg.rhcloud.com` ; then 
	LOCALMIRROR="$HERE/settings.stg.xml"
else 
	LOCALMIRROR="$HERE/settings.prod.xml"
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
        echo "Found pom.xml... attempting to build with 'mvn clean package -Popenshift -DskipTests'" 
        export JAVA_HOME=/etc/alternatives/java_sdk_1.6.0
        export M2_HOME=/etc/alternatives/maven-3.0
        export MAVEN_OPTS="-Xmx208m"
        export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
        pushd ${OPENSHIFT_REPO_DIR} > /dev/null
        mvn --global-settings $LOCALMIRROR --version
        mvn --global-settings $LOCALMIRROR -e clean package -Popenshift -DskipTests
        popd
    fi
fi

user_build.sh
