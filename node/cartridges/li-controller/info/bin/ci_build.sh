#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -n "$JENKINS_URL" ]
then
	REPO_LINK=`echo "${OPENSHIFT_REPO_DIR}" | sed -e "s/\/*$//" `
    rm -rf REPO_LINK
    ln -s ~/$WORKSPACE $REPO_LINK
fi

build.sh