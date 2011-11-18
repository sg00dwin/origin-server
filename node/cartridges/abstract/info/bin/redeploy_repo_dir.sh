#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

rm -rf ${OPENSHIFT_REPO_DIR}* ${OPENSHIFT_REPO_DIR}.[^.]*
git archive --format=tar HEAD | (cd ${OPENSHIFT_REPO_DIR} && tar --warning=no-timestamp -xf -)