#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

if [ -f ${OPENSHIFT_REPO_DIR}setup.py ]
then
    echo "setup.py found.  Setting up virtualenv"
    cd ~/${OPENSHIFT_APP_NAME}/virtenv
    virtualenv ~/${OPENSHIFT_APP_NAME}/virtenv
    . ./bin/activate
    python ${OPENSHIFT_REPO_DIR}setup.py develop
fi

# Run build
user_build.sh

# Start the app
start_app.sh

nurture_app_push.sh $libra_server