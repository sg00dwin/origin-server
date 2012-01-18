#!/bin/bash

# Control application's embedded batch processing (cron) service
SERVICE_NAME=cron
CART_NAME=cron
CART_VERSION=1.4
CART_DIRNAME=${CART_NAME}-$CART_VERSION
CART_INSTALL_DIR=/usr/libexec/li/cartridges
CART_INFO_DIR=$CART_INSTALL_DIR/embedded/$CART_DIRNAME/info
export STOPTIMEOUT=10

function _is_crontab_enabled() {
   [ -f $CART_INSTANCE_DIR/run/crontab.enabled ]  &&  return 0
   return 1

}  #  End of function  _is_crontab_enabled.


function _crontab_status() {
   if _is_crontab_enabled; then
      echo "$SERVICE_NAME batch processing service is enabled" 1>&2
   else
      echo "$SERVICE_NAME batch processing service is disabled" 1>&2
   fi

}  #  End of function  _crontab_status.


function _crontab_enable() {
   if _is_crontab_enabled; then
      echo "$SERVICE_NAME batch processing service is already enabled" 1>&2
   else
      # /usr/bin/crontab -u "$uuid" "$OPENSHIFT_REPO_DIR/.openshift/crontab"
      /usr/bin/crontab "$OPENSHIFT_REPO_DIR/.openshift/crontab"
      wait_to_start_as_user
      touch "$CART_INSTANCE_DIR/run/crontab.enabled"
   fi

}  #  End of function  _crontab_enable.


function _crontab_disable() {
   if _is_crontab_enabled; then
      # /usr/bin/crontab -u "$uuid" -r
      /usr/bin/crontab -r
      rm -f $CART_INSTANCE_DIR/run/crontab.enabled
   else
      echo "$SERVICE_NAME batch processing service is already disabled" 1>&2
   fi

}  #  End of function  _crontab_disable.


function _crontab_reenable() {
   _crontab_disable
   _crontab_enable

}  #  End of function  _crontab_reenable.


#
# main():
#
# Ensure arguments.
if ! [ $# -eq 1 ]; then
    echo "Usage: $0 [enable|reenable|disable|status|start|restart|stop]"
    exit 1
fi

# Import Environment Variables
for f in ~/.env/*; do
    . $f
done

# Cartridge instance dir and control script name.
CART_INSTANCE_DIR="$OPENSHIFT_HOMEDIR/$CART_DIRNAME"
CTL_SCRIPT="$CART_INSTANCE_DIR/${OPENSHIFT_APP_NAME}_${CART_NAME}_ctl.sh"
source ${CART_INFO_DIR}/lib/util

#  Ensure logged in as user.
if whoami | grep -q root
then
    echo 1>&2
    echo "Please don't run script as root, try:" 1>&2
    echo "runuser --shell /bin/sh $OPENSHIFT_APP_UUID $CTL_SCRIPT" 1>&2
    echo 2>&1
    exit 15
fi

case "$1" in
   enable|start)      _crontab_enable   ;;
   disable|stop)      _crontab_disable  ;;
   reenable|restart)  _crontab_reenable ;;
   status)            _crontab_status   ;;
esac

