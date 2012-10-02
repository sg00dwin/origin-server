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

mkdir -p $zend_sandbox
for path in ${symlinks_to_sandbox[*]}; do
    zpath=$zend_install_dir/$path
    echo "Removing ${zpath}"
    rm -rf $zpath
    zdir=`dirname $zpath`
    zfile=`basename $zpath`
    echo "Copying ${zpath}_openshift_original to $zend_sandbox/${path}"
    mkdir -p $zend_sandbox/${path}
    cp -r ${zpath}_openshift_original/* $zend_sandbox/${path}/.
    echo "Linking $zdir/$zfile to $zend_sandbox/$path"
    ln -s $zend_sandbox/$path $zdir/$zfile
    echo "---------------------------------------------------------"
done







