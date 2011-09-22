#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

# Run build
user_build.sh

# Start the app
#start_app.sh

nurture_app_push.sh $libra_server