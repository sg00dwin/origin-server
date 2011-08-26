#!/bin/bash

uuid=$(/usr/libexec/li/cartridges/jenkins/info/bin/launch_jenkins_slave.rb)

echo "Using UUID: $uuid"
ssh -i $OPENSHIFT_DATA_DIR/.ssh/jenkins_id_rsa -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $uuid@jenkslave-mmcgrath3.dev.rhcloud.com "mkdir -p ./jenkslave/data/jenkins && cd ./jenkslave/data/jenkins && wget -q http://$OPENSHIFT_APP_DNS/jnlpJars/slave.jar && java -jar slave.jar"

rhc-ctl-app -a jenkslave -c destroy -b -p ' ' -l mmcgrath3@redhat.com
