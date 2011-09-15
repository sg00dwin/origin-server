#!/bin/bash

# Generate an MCS level from UID
function openshift_mcs_level() {
    SETSIZE=1023
    TIER=$SETSIZE

    ORD=$1
    while [ $ORD -gt $(($TIER)) ] ; do
	ORD=$(($ORD - $TIER))
	TIER=$(($TIER - 1))
    done
    TIER=$(($SETSIZE - $TIER))
    echo s0:c$TIER,c$(($ORD + $TIER))
}

# Import Environment Variables
if [ -d ~/.env ]
then
  for f in ~/.env/*
  do
    . $f
  done
fi

uid=$(id -u "$OPENSHIFT_APP_UUID")

mcs_level=`openshift_mcs_level $uid`

if whoami | grep -q root || ! runcon | grep system_r:libra_t:$mcs_level > /dev/null
then
    echo 1>&2
    echo "Current context: " `runcon` 1>&2
    echo 1>&2
    echo "Please run script in the correct context, try:" 1>&2
    echo "runuser --shell /bin/sh \"$uuid\" -c \"runcon -t libra_t -l $mcs_level<command>\"" 1>&2
    echo 2>&1
    exit 15
fi