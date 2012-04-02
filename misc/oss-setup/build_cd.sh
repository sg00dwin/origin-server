#!/bin/bash
setenforce 0
livecd-creator -c openshift.ks -f fedora_remix --cache=cache -d -v --logfile=livecd.log
setenforce 1
