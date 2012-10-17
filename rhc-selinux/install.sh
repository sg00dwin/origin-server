#!/bin/sh -e

DIRNAME=`dirname $0`
cd $DIRNAME
USAGE="$0 [ --update ]"
if [ `id -u` != 0 ]; then
echo 'You must be root to run this script'
exit 1
fi

if [ $# -eq 1 ]; then
	if [ "$1" = "--update" ] ; then
		time=`ls -l --time-style="+%x %X" openshift-hosted.te | awk '{ printf "%s %s", $6, $7 }'`
		rules=`ausearch --start $time -m avc --raw -se openshift-hosted`
		if [ x"$rules" != "x" ] ; then
			echo "Found avc's to update policy with"
			echo -e "$rules" | audit2allow -R
			echo "Do you want these changes added to policy [y/n]?"
			read ANS
			if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
				echo "Updating policy"
				echo -e "$rules" | audit2allow -R >> openshift-hosted.te
				# Fall though and rebuild policy
			else
				exit 0
			fi
		else
			echo "No new avcs found"
			exit 0
		fi
	else
		echo -e $USAGE
		exit 1
	fi
elif [ $# -ge 2 ] ; then
	echo -e $USAGE
	exit 1
fi

echo "Building and Loading Policy"
set -x
make -f /usr/share/selinux/devel/Makefile
/usr/sbin/semodule -i openshift-hosted.pp

# Fixing the file context on /usr/sbin/httpd
/sbin/restorecon -F -R -v /usr/sbin/httpd
# Fixing the file context on /etc/rc\.d/init\.d/libra
/sbin/restorecon -F -R -v /etc/rc\.d/init\.d/libra
# Fixing the file context on /var/cache/mod_proxy
/sbin/restorecon -F -R -v /var/cache/mod_proxy
# Fixing the file context on /var/lib/dav
/sbin/restorecon -F -R -v /var/lib/dav
# Fixing the file context on /var/run/httpd
/sbin/restorecon -F -R -v /var/run/httpd
# Fixing the file context on /var/log/httpd
/sbin/restorecon -F -R -v /var/log/httpd

