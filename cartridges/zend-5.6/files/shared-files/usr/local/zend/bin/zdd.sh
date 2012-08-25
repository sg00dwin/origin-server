#!/bin/bash 
NAME="Deployment"
if [ -f /etc/zce.rc ];then
    . /etc/zce.rc
else
    echo "/etc/zce.rc doesn't exist!"
    exit 1;
fi
if [ -f $ZCE_PREFIX/bin/shell_functions.rc ];then
    . $ZCE_PREFIX/bin/shell_functions.rc
else
    echo "$ZCE_PREFIX/bin/shell_functions.rc doesn't exist!"
    exit 1;
fi
#check_root_privileges
WEB_USER=$(whoami)
WD_UID=`id -u $WEB_USER`
WD_GID=`id -g $WEB_USER`
. ${ZCE_PREFIX}/bin/shell_functions.rc
WD_INI=${ZCE_PREFIX}/etc/watchdog-deployment.ini
WATCHDOG="${ZCE_PREFIX}/bin/watchdog -c $WD_INI"
BINARY=zdd



start()
{
    launch
}

stop()
{
    _kill
}
status()
{
    $WATCHDOG -i $BINARY
}
case "$1" in
	start)
		start
		sleep 1
                status
		;;
	stop)
		stop
		;;
	restart)
		stop
		sleep 1
		start
		;;
	status)
                status
		;;
	*)
		usage
esac

exit $?
