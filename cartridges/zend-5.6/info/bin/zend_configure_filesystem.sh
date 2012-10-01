#!/bin/sh

symlinks_to_sandbox=(
"etc"
"tmp"
"var"
"gui/lighttpd/etc"
"gui/lighttpd/logs"
"gui/lighttpd/tmp"
"gui/application/data"
)

zend_install_dir="/usr/local/zend"
zend_sandbox="/sandbox/zend"
restore=$1

#This function symlinks the above paths to /sandbox PAM namespace
function create_zend_to_sandbox_links {
  mkdir -p $zend_sandbox
  for path in ${symlinks_to_sandbox[*]}; do
    zpath=$zend_install_dir/$path
    if [ ! -e $zpath ]; then
      echo "Path does not exist $zpath"
      if [ ! -h $zpath ]; then
        continue
      fi
    fi
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    if [ "$restore" == "restore" ]; then
      #echo "Undoing Linking $zdir/$zfile to $zend_sandbox/$path"
      rm -f $zdir/$zfile
      #echo "Removing $zend_sandbox"
      rm -rf $zend_sandbox
    else
      #echo "Backing up $zpath to ${zpath}_openshift_original_$(date +%s)"
      cp -r $zpath ${zpath}_openshift_original_$(date +%s)
      #echo "Copying $zpath to $zend_sandbox/${zfile}"
      mkdir -p $zend_sandbox/${path}
      cp -r $zpath/* $zend_sandbox/${path}/.
      #echo "Removing $zpath"
      rm -rf $zpath
      #echo "Linking $zdir/$zfile to $zend_sandbox/$path"
      ln -s $zend_sandbox/$path $zdir/$zfile
    fi
  done
}


uid=`id -u`
if [ $uid -eq 0 ] ; then
 echo "Running as root..."
 create_zend_to_sandbox_links
fi

