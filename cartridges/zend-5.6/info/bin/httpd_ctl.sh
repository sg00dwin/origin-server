#!/bin/bash -e

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*; do . $f; done
export cartridge_type="zend-5.6"
cartridge_dir=$OPENSHIFT_HOMEDIR/$cartridge_type
export CARTRIDGE_TYPE="zend-5.6"

if [ -f /etc/zce.rc ];then
    . /etc/zce.rc
else
    echo "/etc/zce.rc doesn't exist!"
    exit 1;
fi

translate_env_vars

if ! [ $# -eq 1 ]
then
    echo "Usage: \$0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi

validate_run_as_user

. app_ctl_pre.sh

CART_CONF_DIR=${CARTRIDGE_BASE_PATH}/${cartridge_type}/info/configuration/etc/conf

case "$1" in
    start)
        _state=`get_app_state`
        if [ -f $cartridge_dir/run/stop_lock -o idle = "$_state" ]; then
            echo "Application is explicitly stopped!  Use 'rhc app start -a ${cartridge_type}' to start back up." 1>&2
            exit 0
        else
            src_user_hook pre_start_${cartridge_type}
            set_app_state started
            /usr/sbin/httpd -C "Include $cartridge_dir/conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
            run_user_hook post_start_${cartridge_type}
        fi
    ;;
    graceful-stop|stop)
        app_ctl_stop.sh $1
    ;;
    restart|graceful)
        src_user_hook pre_start_${cartridge_type}
        set_app_state started
        /usr/sbin/httpd -C "Include $cartridge_dir/conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
        run_user_hook post_start_${cartridge_type}
    ;;
esac
