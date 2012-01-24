#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found but disabled for haproxy" 1>&2
fi

if [ -f "${OPENSHIFT_REPO_DIR}/servers.txt" ]
then
    echo "Updating haproxy config"
    cp ${OPENSHIFT_APP_DIR}/conf/haproxy.cfg.template ${OPENSHIFT_APP_DIR}/conf/haproxy.cfg
    cat ${OPENSHIFT_REPO_DIR}/servers.txt >> ${OPENSHIFT_APP_DIR}/conf/haproxy.cfg
else
    echo "Could not find servers.txt in your repo file!"
fi
# Run user build
user_build.sh
