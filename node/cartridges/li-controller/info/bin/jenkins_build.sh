#!/bin/bash -e

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

echo "Executing Jenkins build."
echo
echo "You can track your build at ${JENKINS_URL}job/${OPENSHIFT_APP_NAME}-build"
echo
if jenkins-cli build -s ${OPENSHIFT_APP_NAME}-build
then
    echo "New build has been deployed."
else
    echo "!!!!!!!!"
    echo "Deployment Halted! Previous good build still running!"
    echo "Fix the build and try again".
    echo "!!!!!!!!"
    exit 1
fi