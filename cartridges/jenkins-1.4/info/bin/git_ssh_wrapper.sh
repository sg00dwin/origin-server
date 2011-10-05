#!/bin/bash
mkdir -p "$OPENSHIFT_DATA_DIR/.ssh/"
touch "$OPENSHIFT_DATA_DIR/.ssh/config"
/usr/bin/ssh -o 'StrictHostKeyChecking=no' -F "$OPENSHIFT_DATA_DIR/.ssh/config" $@
#/usr/bin/ssh -o 'IdentityFile=$OPENSHIFT_DATA_DIR/.ssh/jenkins_id_rsa' -o 'StrictHostKeyChecking=no' -F "$OPENSHIFT_DATA_DIR/.ssh/config" $@
