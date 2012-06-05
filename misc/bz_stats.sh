#!/bin/bash
#
# bz_stats - collect statistics about openshift's bugs! 
#
# uses and depends on the bugzilla command line tool provided by the
# python-bugzilla package
#
# This file should be found in the li repository under the misc/ directory
# as well as a file called bugs_history.txt, this should be the data_file.txt
# NOTE: If another data file is used the formatting is expect to fit the 
#       following outline, header line included (space delimited but formated
#       here for convenience.
#
# DATE        Total_Bugs  Blocker_Bugs
# 2012-05-29  305         6
# 
# Author: Adam Miller <admiller@redhat.com>

f_ctrl_c() {
  printf "\n*** Exiting ***\n"
  exit $?
} #end f_ctrl_c
     
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

f_help() {
  printf "Usage: bz_stats.sh [opts] [args]\n"
  printf "\tOptions:\n"
  printf "\t\t-f [data_file.txt] - data file to work with\n"
  printf "\t\t-g [graph_output_file.png] - output graph image to this filename\n"
  printf "\t\t-d Display graph once complete \n"
  printf "\t\t-h Print this help message\n"
} #end f_help

# "global" vars declared here
declare -a openshift_buglist  # The big giant bug list
declare -a blockers           # List of blockers
declare display               # "flag" for display graph or not
declare graph_file          
declare data_file
declare datestamp="$(date +%Y-%m-%d)"

# Make sure bugzilla is installed
if ! bugzilla -h &> /dev/null; then
  printf "ERROR: bugzilla not found, please install the python-bugzilla package\n"
fi

# Make sure gnuplot is installed
if ! gnuplot --version &> /dev/null; then
  printf "ERROR: gnuplot not found, please install the gnuplot package\n"
fi

# parse options/args
while getopts ":hdg:f:" opt; do
  case $opt in
    h)
      f_help
      exit 0
      ;;
    d)
      display="-persist"
      ;;
    g)
      graph_file="$OPTARG"
      ;;
    f)
      data_file="$OPTARG"
      ;;
    *)
      printf "ERROR: INVALID ARG $OPTARG\n"
      f_help
      exit 1
      ;;
  esac
done

# Verify the args - note we don't care if the graph_file is pre-existing or not
if [[ -z "$data_file" || ! -f "$data_file" ]]; then
  printf "ERROR: No data file or incorrect path provided: $data_file\n"
  f_help
  exit 2
elif  [[ -z "$graph_file" ]]; then
  printf "ERROR: No graph file or incorrect path provided: $graph_file\n"
  f_help
  exit 3
fi

if grep "$datestamp" $data_file &> /dev/null; then
  printf "ERROR: Bug report already run for %s and recorded in %s\n" \
    "$datestamp" "$data_file"
  exit 4
fi

printf "Running bugzilla query, this might take a few minutes ...\n"
# Read in all the bugs into an array so we can hold them and create stats
### Throw stderr to devnull, it throws intermittent python io errors 
mapfile openshift_buglist < <( bugzilla query -p OpenShift \
  --bug_status='NEW,ASSIGNED,NEEDINFO,ON_DEV,MODIFIED,POST,ON_QA,REOPENED,VERIFIED' \
  --outputformat='%{bug_id}:%{assigned_to}:%{priority}:%{bug_severity}:%{component}:%{bug_status}:%{keywords}' ) \
  2> /dev/null

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

  
printf "%s %s %s\n" \
  "$datestamp" \
  "${#openshift_buglist[@]}" \
  "${#blockers[@]}" >> $data_file

gnuplot $display <<EOF
set term png
set output "$graph_file"
set key top left outside horizontal autotitle columnhead
set style fill solid border -1
set xtics rotate by 90 offset 0,-5 out nomirror
set boxwidth 0.5 relative
set style data histograms
set style histogram rowstacked
plot "$data_file" using 2:xticlabels(1) lc rgb 'green', "" using 3 lc rgb 'red'
set term wxt
plot "$data_file" using 2:xticlabels(1) lc rgb 'green', "" using 3 lc rgb 'red'
EOF
