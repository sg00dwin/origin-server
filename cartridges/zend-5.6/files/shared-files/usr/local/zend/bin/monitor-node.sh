#!/bin/bash  
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
WD_INI=${ZCE_PREFIX}/etc/watchdog-monitor.ini
WATCHDOG="${ZCE_PREFIX}/bin/watchdog -c $WD_INI"
BINARY=monitor
NAME="$PRODUCT_NAME Monitor node"
umask 002 

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
		# since these SQLite DBs are created on the fly by MonitorNode in the first init, we must set them to proper perms			
		#touch ${ZCE_PREFIX}/var/db/monitor ${ZCE_PREFIX}/var/db/monitor_codetracing
		#chown $WEB_USER:$WEB_USER ${ZCE_PREFIX}/var/db/monitor ${ZCE_PREFIX}/var/db/monitor_codetracing
		#chmod 664 ${ZCE_PREFIX}/var/db/monitor ${ZCE_PREFIX}/var/db/monitor_codetracing
		start
		sleep 1
                status
		;;
	stop)
		stop

		# Clean monitor SHM files (JIRA issue ZSRV-965)
		for DIR in $ZCE_PREFIX/tmp /tmp; do
			rm -f $DIR/zshm_CollectorUptimeSHM_*
			rm -f $DIR/zshm_MonitorDumpHash_*
			rm -f $DIR/zshm_monitor_ZMRequestsStatContainerSHM_*
		done

		rm -f ${ZCE_PREFIX}/tmp/monitor.{app,wd}
		;;
	restart)
		stop

		# Clean monitor SHM files (JIRA issue ZSRV-965)
		for DIR in $ZCE_PREFIX/tmp /tmp; do
			rm -f $DIR/zshm_CollectorUptimeSHM_*
			rm -f $DIR/zshm_MonitorDumpHash_*
			rm -f $DIR/zshm_monitor_ZMRequestsStatContainerSHM_*
		done

		rm -f ${ZCE_PREFIX}/tmp/monitor.{app,wd}
		sleep 1
		start
		;;
	status)
		status
		;;
	*)
		usage
                exit 1
esac

exit $?
