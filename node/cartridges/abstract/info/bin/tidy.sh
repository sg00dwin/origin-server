#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

pushd ${OPENSHIFT_HOME_DIR}git/${OPENSHIFT_APP_NAME}.git > /dev/null
git gc --prune --aggressive
popd > /dev/null

for f in ~/${OPENSHIFT_LOG_DIR}/*
do
     echo > $f
done

rm -rf ${OPENSHIFT_TMP_DIR}* ${OPENSHIFT_TMP_DIR}.[^.]*