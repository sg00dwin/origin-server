#!/bin/bash

cd ~/git/${OPENSHIFT_APP_NAME}.git
rm -rf *
export GIT_SSH=/usr/libexec/li/cartridges/haproxy-1.4/info/bin/ssh
git clone --bare $1
git add remote haproxy $1
