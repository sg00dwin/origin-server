#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Create a link for each file in user config to server standalone/config
if [ -d ${OPENSHIFT_REPO_DIR}.openshift/config ]
then
  for f in ${OPENSHIFT_REPO_DIR}.openshift/config/*
  do
    target=$(basename $f)
    # Remove any target that is being overwritten
    if [ -e "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target" ]
    then
       echo "Removing existing $target"
       rm -rf "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/$target"
    fi
    ln -s $f "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration/"
  done
fi
# Now go through the standalone/configuration and remove any stale links from previous
# deployments, https://bugzilla.redhat.com/show_bug.cgi?id=734380
for f in "${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/configuration"/*
do
    target=$(basename $f)
    if [ ! -e $f ]
    then
        echo "Removing obsolete $target"
        rm -rf $f
    fi
done

user_deploy.sh