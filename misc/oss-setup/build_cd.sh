#!/bin/bash
setenforce 0
livecd-creator -c openshift.ks -f openshift_origin --cache=cache -d -v --logfile=livecd.log
setenforce 1
