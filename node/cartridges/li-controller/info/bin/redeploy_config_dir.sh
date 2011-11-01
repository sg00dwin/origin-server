#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

rm -rf ${OPENSHIFT_REPO_DIR}.openshift/config/* ${OPENSHIFT_REPO_DIR}.openshift/config/.[^.]*

if ! $(git archive --format=tar HEAD | (cd ${OPENSHIFT_REPO_DIR} && tar --warning=no-timestamp -xf - ".openshift/config/*" > /dev/null 2>&1))
then
	echo "Nothing found in .openshift/config/* to redeploy"
fi