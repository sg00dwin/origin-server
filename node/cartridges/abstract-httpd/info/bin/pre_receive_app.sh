#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ -f ~/.env/JENKINS_URL ]
then
  stop_app.sh
fi