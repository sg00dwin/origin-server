#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

user_build.sh

user_deploy.sh

start_app.sh

user_post_deploy.sh

nurture_app_push.sh $libra_server