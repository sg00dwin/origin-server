#!/bin/bash

application="$1"
include_git="$2"

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ "$include_git" = "INCLUDE_GIT" ]
then
  ~/git/${application}.git/hooks/pre-receive 1>&2
  echo "Removing old git repo - ~/git/${application}.git/" 1>&2
  /bin/rm -rf ~/git/${application}.git/[^h]*/*
else
  stop_app.sh 1>&2
fi

echo "Removing old data dir - ~/${application}/data/*" 1>&2
/bin/rm -rf ~/${application}/data/* ~/${application}/data/.[^.]*


if [ "$include_git" = "INCLUDE_GIT" ]
then
  echo "Restoring ~/git/${application}.git and ~/${application}/data" 1>&2
  /bin/tar --overwrite -xmz ./${application}/data ./git --exclude=git/${application}.git/hooks 1>&2
  GIT_DIR=~/git/${application}.git/ ~/git/${application}.git/hooks/post-receive 1>&2
else
  /bin/tar --overwrite -xmz ./${application}/data 1>&2
  start_app.sh 1>&2
fi

for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_RESTORE$/) print ENVIRON[a] }'`
do
    echo "Running extra restore: $(/bin/basename $cmd)" 1>&2
    $cmd
done
