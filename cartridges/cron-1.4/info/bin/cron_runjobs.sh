#!/bin/bash

# Constants.
SERVICE_NAME=cron
CART_NAME=cron
CART_VERSION=1.4
CART_DIRNAME=${CART_NAME}-$CART_VERSION
CART_INSTALL_DIR=/usr/libexec/li/cartridges
CART_INFO_DIR=$CART_INSTALL_DIR/embedded/$CART_DIRNAME/info
CART_DIR=${CART_DIR:-$CART_INSTALL_DIR}

function log_message() {
   msg=${1-""}
   [ -z "$msg" ]  &&  return 0
   logger -i -s "user-cron-jobs" -p user.info "`date`: $msg"
}


#
# main():
#

# Ensure arguments.
if ! [ $# -eq 1 ]; then
    freqs=$(cat $CART_INFO_DIR/configuration/frequencies | tr '\n' '|')
    echo "Usage: $0 <${freqs%?}>"
    exit 22
fi

freq=$1

# Import Environment Variables
for f in ~/.env/*; do
    . $f
done

source "$CART_INFO_DIR/configuration/limits"

log_message ":START: $freq cron run for libra user '$OPENSHIFT_APP_UUID'"

# First up check if the cron jobs are enabled.
CART_INSTANCE_DIR="$OPENSHIFT_HOMEDIR/$CART_DIRNAME"
if [ ! -f $CART_INSTANCE_DIR/run/jobs.enabled ]; then
   # Jobs are not enabled - just exit.
   exit 0
fi

# Run all the scripts in the $freq directory if it exists.
SCRIPTS_DIR="$OPENSHIFT_REPO_DIR/.openshift/cron/$freq"
if [ -d "$SCRIPTS_DIR" ]; then
   # Run all scripts in the scripts directory serially.
   executor=bash
   [ -n "$MAX_RUN_TIME" ]  &&  executor="timeout $MAX_RUN_TIME bash"

   script_list=$(ls "$SCRIPTS_DIR")
   $executor <<RUN_USER_SCRIPTS_EOF
      ls "$SCRIPTS_DIR" | while read f; do
         [ ! -x "$SCRIPTS_DIR/\$f" ]  &&  chmod +x "$SCRIPTS_DIR/\$f"
         "$SCRIPTS_DIR/\$f" >> $CART_INSTANCE_DIR/log/cron.$freq.log 2>&1
      done
RUN_USER_SCRIPTS_EOF

fi

log_message ":END: $freq cron run for libra user '$OPENSHIFT_APP_UUID'"
exit 0
