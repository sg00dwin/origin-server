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

redeploy_repo_dir.sh

if [ -d ${OPENSHIFT_REPO_DIR}.openshift/config ]
then
  for f in ${OPENSHIFT_REPO_DIR}.openshift/config/*
  do
    target=$(basename $f)
    if [ -e "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target" ]
    then
       echo "Removing existing $target"
       rm -rf "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target"
    fi
    ln -s $f "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/"
  done
fi

if [ -f ${OPENSHIFT_REPO_DIR}pom.xml ] && ! $SKIP_MAVEN_BUILD
then
  echo "Found pom.xml... attempting to build with 'mvn clean package -Popenshift -DskipTests'" 
  export JAVA_HOME=/etc/alternatives/java_sdk_1.6.0
  export M2_HOME=/etc/alternatives/maven-3.0
  export M2=$M2_HOME/bin
  export MAVEN_OPTS="-Xmx208m"
  export PATH=$JAVA_HOME/bin:$M2:$PATH
  pushd ${OPENSHIFT_REPO_DIR} > /dev/null
  mvn --version
  mvn clean package -Popenshift -DskipTests
  popd
fi

# Run build
user_build.sh

# Start the app
start_app.sh

nurture_app_push.sh $libra_server
