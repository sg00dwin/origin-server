#!/bin/bash

function git_mirror_push() {
    gears=${1:-"all-gears"}
    app_git_dir=~/git/${OPENSHIFT_APP_NAME}.git/

    #  Need to push twice so that mirror states are also synced.
    GIT_DIR=$app_git_dir  git push $gears --mirror
    GIT_DIR=$app_git_dir  git push $gears --mirror
}


function get_gear_git_mirrors() {
    app_git_dir=~/git/${OPENSHIFT_APP_NAME}.git/
    echo $(GIT_DIR=$app_git_dir  git remote -v  |     \
              grep -E "^gear\-.*(push)"  |  awk '{print $1}')
}


# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

export GIT_SSH="/usr/libexec/li/cartridges/haproxy-1.4/info/bin/ssh"

#  Optimized case - push to all mirrors.
if ! git_mirror_push all-gears; then
    #  Failure case - we have a bad remote/mirror - so do it one by one.
    for gear_name in $(get_gear_git_mirrors); do
        git_mirror_push "$gear_name"
    done
fi

user_deploy.sh
