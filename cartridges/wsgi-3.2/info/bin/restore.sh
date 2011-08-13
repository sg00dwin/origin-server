#!/bin/bash

application="$1"
include_git="$2"

~/git/${application}.git/hooks/pre-receive 1>&2

if [ "$include_git" = "INCLUDE_GIT" ]
then
  echo "Removing old git repo - ~/git/${application}.git/" 1>&2
  /bin/rm -rf ~/git/${application}.git/[^h]*/*
fi

echo "Removing old data dir - ~/${application}/data/*" 1>&2
/bin/rm -rf ~/${application}/data/* ~/${application}/data/.[^.]*


if [ "$include_git" = "INCLUDE_GIT" ]
then
  echo "Restoring ~/git/${application}.git and ~/${application}/data" 1>&2
  /bin/tar --overwrite -xvmz ./${application}/data ./git --exclude=git/${application}.git/hooks 1>&2
else
  /bin/tar --overwrite -xvmz ./${application}/data 1>&2
fi

GIT_DIR=~/git/${application}.git/ ~/git/${application}.git/hooks/post-receive 1>&2
