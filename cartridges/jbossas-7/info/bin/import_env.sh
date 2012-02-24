#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done


ENV=`ls ${OPENSHIFT_HOMEDIR}/.env/*`
for e in ${ENV}
do
	v=`sed 's/export //' $e`
	OPENSHIFT_ENV_TO_PROPS="${OPENSHIFT_ENV_TO_PROPS} -D${v}"
done

export OPENSHIFT_ENV_TO_PROPS
echo "OPENSHIFT_ENV_TO_PROPS=$OPENSHIFT_ENV_TO_PROPS"
