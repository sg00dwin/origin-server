#!/bin/sh

file_list=(
"/usr/local/zend/etc"
"/usr/local/zend/tmp"
"/usr/local/zend/var"
"/usr/local/zend/gui/lighttpd/etc"
"/usr/local/zend/gui/lighttpd/logs"
"/usr/local/zend/gui/lighttpd/tmp"
"/usr/local/zend/gui/application/data"
)

target_pam="/tmp/zend"
restore=$1

function create_links {
  for zpath in ${file_list[*]}; do
    if [ ! -e $zpath ]; then
      echo "Path does not exist $zpath"
      if [ ! -h $zpath ]; then
        continue
      fi
    fi
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    if [ "$restore" == "restore" ]; then
      echo "Undoing Linking $zdir/$zfile to $target_pam/$zdir/$zfile"
      rm -f $zdir/$zfile
      echo "Undoing Moving $zpath to $zdir/${zfile}_openshift_original"
      mv $zdir/${zfile}_openshift_original $zpath
    else
      echo "Moving $zpath to $zdir/${zfile}_openshift_original"
      mv $zpath $zdir/${zfile}_openshift_original
      echo "Linking $zdir/$zfile to $target_pam/$zdir/$zfile"
      ln -s $target_pam/$zdir/$zfile $zdir/$zfile
    fi
  done
}

function copy_fs_to_pam {
  target_location=$1
  if [ ! -d $target_location ]; then
    echo "Target location '#target_location' does not exist."
    return
  fi
  echo "Copying file system to location $target_location"
  for zpath in ${file_list[*]}; do
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    if [ ! -f $zdir/${zfile}_openshift_original ]; then
      echo "File $zdir/${zfile}_openshift_original does not exist"
      continue
    fi
    echo "Copying $zdir/${zfile}_openshift_original $target_location/$zdir/$zfile"
    cp -rf $zdir/${zfile}_openshift_original $target_location/$zdir/$zfile
  done
}

uid=`id -u`
if [ $uid -eq 0 ] ; then
 echo "Running as root..."
 create_links
else
 echo "Running as non-root..."
 mkdir -p $target_pam
 copy_fs_to_pam $target_pam
fi
