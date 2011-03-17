#!/bin/sh
#
#
# Initialize quotas for Libra
#
#
# Get libra_dir configured value
if [ -f /etc/libra/node.conf ]
then
    . /etc/libra/node.conf
fi

# override if the user requests it explicitly
if [ -n "$1" ]
then
    libra_dir=$1
fi

# default if no one gives you a good answer
libra_dir=${libra_dir:=/var/lib/libra}

function get_filesystem() {
    # $1=libra_dir
    df $1 | tail -1 | tr -s ' ' | cut -d' ' -f 1
}

function get_mountpoint() {
    df $1 | tail -1 | tr -s ' ' | cut -d' ' -f 6
}

function get_mount_options() {
    mount | grep $1 | sed -e 's/^.*(// ; s/).*$// '
}

LIBRA_FILESYSTEM=`get_filesystem $libra_dir`
LIBRA_MOUNTPOINT=`get_mountpoint $libra_dir`
QUOTA_FILE=${LIBRA_MOUNTPOINT}/aquota.user


#
# Add quota options to libra filesystem mount
#
function_update_fstab() {
    # LIBRA_FILESYSTEM=$1
    CURRENT_OPTIONS=`get_mount_options $1`
    QUOTA_OPTIONS=usrjquota=aquota.user,jqfmt=vfsv0
    NEW_OPTIONS=${CURRENT_OPTIONS},${QUOTA_OPTIONS}
    # check before you replace.
    # NOTE: double quotes - Variables are shell-substituted before perl runs
    perl -p -i -e "m:$1: && s/${CURRENT_OPTIONS}/${NEW_OPTIONS}/" /etc/fstab
}

#
# Initialize the quota database on the filesystem
#
function init_quota_db() {
    # LIBRA_MOUNTPOINT=$1
    # create the quota DB file on the filesystem
    QUOTA_FILE=$1/aquota.user
    touch $QUOTA_FILE
    chmod 600 $QUOTA_FILE
    # initialize quota db on the filesystem
    quotacheck -cmu $1
}


#
# MAIN
#
update_fstab $LIBRA_FILESYSTEM

init_quota_db $LIBRA_MOUNTPOINT

# remount to enable
mount -o remount $LIBRA_FILESYSTEM
# enable quotas
quotaon -a