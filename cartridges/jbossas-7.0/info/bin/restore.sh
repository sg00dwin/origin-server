#!/bin/bash

application="$1"
include_git="$2"

if [ "$include_git" = "INCLUDE_GIT" ]
then
  /bin/rm -rf ~/git/${application}.git/[^h]*/*
fi

/bin/rm -rf ~/${application}/data/* ~/${application}/data/.[^.]*


if [ "$include_git" = "INCLUDE_GIT" ]
then
  /bin/tar --overwrite -xvmz ./${application}/data ./git --exclude=git/${application}.git/hooks
else
  /bin/tar --overwrite -xvmz ./${application}/data
fi