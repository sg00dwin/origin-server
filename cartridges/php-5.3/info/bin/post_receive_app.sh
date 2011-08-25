#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

if [ -f ~/${OPENSHIFT_APP_NAME}/repo/deplist.txt ]
then
    for f in $(cat ~/${OPENSHIFT_APP_NAME}/repo/deplist.txt)
    do
        echo "Checking pear: $f"
        echo
        if pear list "$f" > /dev/null
        then
            pear upgrade "$f"
        else
            pear install --alldeps "$f"
        fi
    done
fi

# Run build
user_build.sh

# Start the app
start_app.sh

nurture_app_push.sh $libra_server
