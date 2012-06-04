#!/bin/bash
#
# bz_stats - collect statistics about openshift's bugs! 
#
# uses and depends on the bugzilla command line tool provided by the
# python-bugzilla package
# 
# Author: Adam Miller <admiller@redhat.com>

f_ctrl_c() {
  printf "\n*** Exiting ***\n"
  exit $?
}
     
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

# "global" vars declared here
declare -a openshift_buglist  # The big giant bug list
declare -a blockers           # List of blockers

# Make sure bugzilla is installed
if ! bugzilla -h &> /dev/null; then
  printf "ERROR: bugzilla not found, please install the python-bugzilla package\n"
fi

printf "Running bugzilla query, this might take a few minutes ...\n"

# Read in all the bugs into an array so we can hold them and create stats
mapfile openshift_buglist < <( bugzilla query -p OpenShift \
  --bug_status='NEW,ASSIGNED,NEEDINFO,ON_DEV,MODIFIED,POST,ON_QA,REOPENED,VERIFIED' \
  --outputformat='%{bug_id}:%{assigned_to}:%{priority}:%{bug_severity}:%{component}:%{bug_status}:%{keywords}' )


# Obtain a list of blocker bugs based on status and severity
for b in "${openshift_buglist[@]}"
do
  b_comp="$(printf "$b" | cut -d: -f5)"
  if [[ "$b_comp" =~ ^\[\'(Cartridges|Website|REST API|Command Line Interface|Broker|Cartridges)\'\]$ ]]; then
    b_kw="$(printf "$b" | cut -d: -f7)"
    if [[ ! "$b_kw" =~ FutureFeature ]]; then
      b_stat="$(printf "$b" | cut -d: -f6)"
      if [[ "$b_stat" =~ ^(NEW|ASSIGNED|MODIFIED|ON_DEV)$ ]]; then
        b_sev="$(printf "$b" | cut -d: -f4)"
        if [[ "$b_sev" =~ ^(unspecified|urgent|high|medium)$ ]]; then
            blockers+=( "$b" )
        fi
      fi
    fi
  fi
done

printf "Total number of bugs: ${#openshift_buglist[@]}\n"
printf "Total number of blockers: ${#blockers[@]}\n"

