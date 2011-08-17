#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

uid=$(id -u "$OPENSHIFT_APP_UUID")
c_val="c$(($uid/1023)),c$(($uid%1023))"

if whoami | grep -q root || ! runcon | grep system_r:libra_t:s0:$c_val > /dev/null
then
    echo 1>&2
    echo "Please run script in the correct context, try:" 1>&2
    echo "runuser --shell /bin/sh \"$uuid\" -c \"runcon -t libra_t -l s0:$c_val <command>\"" 1>&2
    echo 2>&1
    exit 15
fi