include_git="$1"

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ "$include_git" = "INCLUDE_GIT" ]
then
  echo "Restoring ~/git/${OPENSHIFT_APP_NAME}.git and ~/${OPENSHIFT_APP_NAME}/data" 1>&2
  /bin/tar --strip=2 --overwrite -xmz "./*/${OPENSHIFT_APP_NAME}/data" "./*/git" --exclude="./*/git/${OPENSHIFT_APP_NAME}.git/hooks" 1>&2  
else
  echo "Restoring ~/${OPENSHIFT_APP_NAME}/data" 1>&2
  /bin/tar --strip=2 --overwrite -xmz "./*/${OPENSHIFT_APP_NAME}/data" 1>&2
fi