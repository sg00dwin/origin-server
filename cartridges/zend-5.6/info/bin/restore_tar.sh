#!/bin/bash

include_git="$1"

# Import Environment Variables
for f in ~/.env/*; do . $f; done
cartridge_type="zend-5.6"
cartridge_dir=$OPENSHIFT_HOMEDIR/$cartridge_type

# Allow old and new backups without an error message from tar by
# including all data dirs and excluding the cartridge ones.
includes=( "./*/*/data" "./*/zend-5.6/etc" "./*/zend-5.6/var" "./*/zend-5.6/gui" )

transforms=( --transform="s|${cartridge_type}/data|app-root/data|" --transform="s|git/.*\.git|git/${OPENSHIFT_GEAR_NAME}.git|" )

excludes=()
carts=( $(source /etc/openshift/node.conf; ls $CARTRIDGE_BASE_PATH ; ls $CARTRIDGE_BASE_PATH/embedded) )

for cdir in ${carts[@]}
do
    excludes=( "${excludes[@]}" --exclude="./*/$cdir/data" )
done

if [ "$include_git" = "INCLUDE_GIT" ]
then
  echo "Restoring ~/git/${OPENSHIFT_GEAR_NAME}.git and ~/app-root/data" 1>&2
  excludes=( "${excludes[@]}" --exclude="./*/git/*.git/hooks" )
  includes=( "${includes[@]}" "./*/git" )
else
  echo "Restoring ~/app-root/data" 1>&2
fi

/bin/tar --strip=2 --overwrite -xmz "${includes[@]}" "${transforms[@]}" "${excludes[@]}" 1>&2
