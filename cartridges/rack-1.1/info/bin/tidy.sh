#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/li-controller/info/lib/util

if [ -d ${OPENSHIFT_REPO_DIR}log/ ]
then
    client_message "Emptying log dir: ${OPENSHIFT_REPO_DIR}log/"
    rm -rf ${OPENSHIFT_REPO_DIR}log/* ${OPENSHIFT_REPO_DIR}log/.[^.]*
fi

if [ -d ${OPENSHIFT_REPO_DIR}tmp/ ]
then
    client_message "Emptying tmp dir: ${OPENSHIFT_REPO_DIR}tmp/"
    rm -rf ${OPENSHIFT_REPO_DIR}tmp/* ${OPENSHIFT_REPO_DIR}tmp/.[^.]*
fi