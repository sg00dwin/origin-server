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

function threaddump() {
    if [$PID .eq ""]; then
        echo "Application is stopped"
        exit 1
    else 
        kill -3 $PID
    fi
}

PID=`ps -e -o pid,command | grep Rack | grep $2 | grep $3 | awk 'BEGIN {FS=" "}{print $1}'`

case "$1" in
    threaddump)
        threaddump
    ;;
esac
