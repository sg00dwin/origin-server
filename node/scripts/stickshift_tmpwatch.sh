#!/bin/bash

# This script will clean up peoples /tmp directories.  Anything not modified in
# 10 days will get deleted.

HOMEDIR='/var/lib/openshift/'
for f in $(ls $HOMEDIR)
do
	[ -d $HOMEDIR/$f/.tmp/$f ] && /usr/sbin/tmpwatch -m -f 10d $HOMEDIR/$f/.tmp/$f
done
