#!/bin/bash
set -e

application="$1"
include_git="$2"
  
GIT_DIR=~/git/${application}.git/
  
if [ "$include_git" = "INCLUDE_GIT" ]
then
  GIT_DIR="$GIT_DIR" $GIT_DIR/hooks/pre-receive
  /bin/rm -rf ~/git/${application}.git/[^h]*/*
fi

/bin/rm -rf ~/${application}/data/* ~/${application}/data/.[^.]*

if [ "$include_git" = "INCLUDE_GIT" ]
then
  /bin/tar --overwrite -xvmz ./${application}/data ./git --exclude=git/${application}.git/hooks
  GIT_DIR="$GIT_DIR" $GIT_DIR/hooks/post-receive
else
  /bin/tar --overwrite -xvmz ./${application}/data
fi