#!/bin/bash

cd ~/git/${OPENSHIFT_APP_NAME}
rm -rf *
git clone --bare $1
git add remote haproxy $1
