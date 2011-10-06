#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ -f ~/.env/OPENSHIFT_CI_TYPE ]
then
  stop_app.sh
fi