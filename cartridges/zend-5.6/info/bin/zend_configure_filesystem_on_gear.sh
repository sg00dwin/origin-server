#!/bin/sh

paths=(
"etc"
"tmp"
"var"
"gui/lighttpd/etc"
"gui/lighttpd/logs"
"gui/lighttpd/tmp"
"gui/application/data"
)

zend_sandbox="/sandbox/zend"

#function copy_files_to_sandbox {
#  source_location=$1
#  target_location=$zend_sandbox
#  mkdir -p $target_location
#  echo "Copying files from $source_location system to location $target_location"
#  cp -rf $source_location/* $target_location/.
#  FILES=$(find $target_location -type f -name *.ini -or -name *.conf -or -name *.xml)

#  for zpath in ${FILES}; do
#    zdir=`dirname $zpath`
#    zfile=`basename $zpath`
#    if [ ! -e $zdir/${zfile} ]; then
#      echo "File $zdir/${zfile} does not exist"
#      continue
#    fi
#    #echo "Replacing ###OPENSHIFT_INTERNAL_IP### with ${IP_ADDRESS} in $zdir/${zfile}"
#    sed -i "s/###OPENSHIFT_INTERNAL_IP###/${IP_ADDRESS}/g" $zdir/${zfile}
#    #echo "Replacing ###OPENSHIFT_GEAR_DIR### with $target_location in $zdir/${zfile}"
#    sed -i "s|###OPENSHIFT_GEAR_DIR###|${target_location}|g" $zdir/${zfile}
#    #echo "Replacing ###UID### with $USER_ID in $zdir/${zfile}"
#    sed -i "s/###UID###/${USER_ID}/g" $zdir/${zfile}
#    #echo "Replacing ###GID### with $GROUP_ID in $zdir/${zfile}"
#    sed -i "s/###GID###/${GROUP_ID}/g" $zdir/${zfile}
#  done
#}

function copy_files_to_cartridge_dir {
  source_location=$1
  target_location=$CART_DIR
  if [ ! -d $target_location ]; then
    echo "Target location '#target_location' does not exist."
    return
  fi
  echo "Copying files from $source_location to location $target_location"
  cp -rf $source_location/* $target_location/.
  FILES=$(find $target_location -type f -name *.ini -or -name *.conf -or -name *.xml)

  for zpath in ${FILES}; do
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    if [ ! -e $zdir/${zfile} ]; then
      echo "File $zdir/${zfile} does not exist"
      continue
    fi
    #echo "Replacing ###OPENSHIFT_INTERNAL_IP### with ${IP_ADDRESS} in $zdir/${zfile}"
    sed -i "s/###OPENSHIFT_INTERNAL_IP###/${IP_ADDRESS}/g" $zdir/${zfile}
    #echo "Replacing ###OPENSHIFT_GEAR_DIR### with ${CART_DIR} in $zdir/${zfile}"
    sed -i "s|###OPENSHIFT_GEAR_DIR###|${CART_DIR}|g" $zdir/${zfile}
    #echo "Replacing ###UID### with $USER_ID in $zdir/${zfile}"
    sed -i "s/###UID###/${USER_ID}/g" $zdir/${zfile}
    #echo "Replacing ###GID### with $GROUP_ID in $zdir/${zfile}"
    sed -i "s/###GID###/${GROUP_ID}/g" $zdir/${zfile}
  done
}

#This function symlinks the above paths in /sandbox to cartridge directory in the gear
function create_sandbox_to_cart_dir_links {
  for path in ${paths[*]}; do
    zpath=$zend_sandbox/$path
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    mkdir -p $zdir
    #echo "Linking $zdir/$zfile to $CART_DIR/$path"
    ln -s $CART_DIR/$path $zdir/$zfile
  done
}

function change_ownership_to_user {
  for path in ${paths[*]}; do
    zpath=${CART_DIR}/$path
    if [ ! -e $zpath ]; then
      echo "Path does not exist $zpath"
      if [ ! -h $zpath ]; then
        continue
      fi
    fi
    chown -R $USER_ID:$GROUP_ID $zpath
  done
}


FILES_DIR=$1
CART_DIR=$2
USER_ID=$3
GROUP_ID=$4
IP_ADDRESS=$5

echo "FILES_DIR=${FILES_DIR} CART_DIR=${CART_DIR} USER_ID=${USER_ID} GROUP_ID=${GROUP_ID} IP_ADDRESS=${IP_ADDRESS}"

uid=`id -u`
if [ $uid -eq 0 ] ; then
  echo "Running as root"
  copy_files_to_cartridge_dir  $FILES_DIR
  change_ownership_to_user
else
  echo "Running as non-root..."
  #copy_files_to_sandbox $FILES_DIR
  create_sandbox_to_cart_dir_links
fi

