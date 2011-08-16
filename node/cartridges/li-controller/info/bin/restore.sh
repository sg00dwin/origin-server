#!/bin/bash

application="$1"
include_git="$2"

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

~/git/${application}.git/hooks/pre-receive 1>&2

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

restore_tar.sh $include_git

if [ "$include_git" = "INCLUDE_GIT" ]
then
  GIT_DIR=~/git/${application}.git/ ~/git/${application}.git/hooks/post-receive 1>&2  
else
  start_app.sh 1>&2
fi

for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_RESTORE$/) print ENVIRON[a] }'`
do
    echo "Running extra restore: $(/bin/basename $cmd)" 1>&2
    $cmd
done
