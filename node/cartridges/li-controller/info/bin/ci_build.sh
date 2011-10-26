#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -n "$JENKINS_URL" ]
then
	REPO_LINK=${OPENSHIFT_APP_DIR}/runtime/repo
    rm -rf $REPO_LINK
    ln -s ~/$WORKSPACE $REPO_LINK
fi

build.sh