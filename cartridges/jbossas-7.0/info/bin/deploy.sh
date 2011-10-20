#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

user_deploy.sh