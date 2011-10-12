#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

# Run when jenkins is not being used or run when inside a build
if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found!  Recreating virtenv" 1>&2
    rm -rf "${OPENSHIFT_APP_DIR}"/virtenv/*
fi

if [ -f ${OPENSHIFT_REPO_DIR}setup.py ]
then
    echo "setup.py found.  Setting up virtualenv"
    cd ~/${OPENSHIFT_APP_NAME}/virtenv

    # Hack to fix symlink on rsync issue
    /bin/rm -f lib64
    virtualenv ~/${OPENSHIFT_APP_NAME}/virtenv
    . ./bin/activate
    python ${OPENSHIFT_REPO_DIR}setup.py develop
    virtualenv --relocatable ~/${OPENSHIFT_APP_NAME}/virtenv
fi

# Run build
user_build.sh
