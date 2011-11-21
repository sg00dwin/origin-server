#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

curl -s -O /dev/null -d "json_data=\"{\"app_uuid\":\"${OPENSHIFT_APP_UUID}\",\"action\":\"push\"}\"" https://${libra_server}/broker/nurture >/dev/null 2>&1 &