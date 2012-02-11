#!/bin/bash -e

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ $# -eq 2 ]
then
    echo "Usage: \$0 APP_ID UUID"
    exit 1
fi

PID=`ps -e -o pid,command | grep Rack | grep $1 | grep $2 | awk 'BEGIN {FS=" "}{print $1}'`

if [$PID .eq ""]; then
    echo "Application is stopped. Ruby/Rack applications must be started by accessing the URL for a thread dump"
else 
    kill -3 $PID
fi
