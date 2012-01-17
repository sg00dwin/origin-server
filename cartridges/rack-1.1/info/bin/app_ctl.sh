#!/bin/bash -e

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ $# -eq 3 ]
then
    echo "Usage: \$0 [threaddump] APP_ID UUID"
    exit 1
fi

validate_user_context.sh

case "$1" in
    *)
        app_ctl_impl.sh $1 $2 $3
    ;;
esac