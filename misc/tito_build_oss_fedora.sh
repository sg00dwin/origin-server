#!/bin/bash
#
# misc/tito_build_oss_fedora.sh
#
#   This script will build all opensource components using tito and mock on a 
#   local machine in order to create a "cleanly built" repository. Attempting
#   to mimic having an actual build system the best we can.
# 
# Author: Adam Miller <admiller@redhat.com>

f_ctrl_c()
{
  printf "\n*** Exiting ***\n"
  exit $?
}
     
# trap int (ctrl-c)
trap control_c SIGINT

# "Global" variables
sibling_dirs=( "os-client-tools" "crankcase" )
declare -a failed_builds
declare -a failed_builds_paths

# Slight sanity checking
if [[ -n "$1" ]]; then
  mock_target="$1"
  tito_working_dir=/tmp/tito/build_oss_fedora/$1
else
  printf "ERROR: Invalid argument or no argument given\n"
  cat <<EOF
Usage: misc/tito_build_oss_fedora.sh mock_build_target
    mock_build_target: mock config name, ex: fedora-16-x86_64
EOF
  exit 1
fi

# check mock stuff 
mock --version &> /dev/null
if [[ $? -ne 0 ]]; then
  printf "ERROR: mock not installed or not in current \$PATH\n"
  exit 2
fi
if [[ ! -f /etc/mock/${mock_target}.cfg ]]; then
  printf "ERROR: $mock_target is an invalid mock build target\n"
  printf "\tNo /etc/mock/${mock_target}.cfg found\n"
  exit 3
fi

# clean the old build working dir
if [[ -d $tito_working_dir ]]; then
  rm -fr $tito_working_dir
  mkdir -p $tito_working_dir
fi

# Run throught he siblings and do the builds
for d in ${sibling_dirs[@]}
do
  if [[ ! -d ../$d ]]; then
    printf "ERROR: Directory $d not a sibling of current directory\n"
    exit 4
  fi
  pushd ../$d
    for i in $(find . -name *.spec)
    do
      pushd $(dirname $i)
        tito build \
          --builder mock \
          --builder-arg mock\=$mock_target \
          --rpm \
          --test \
          -o $tito_working_dir
        
        if [[ $? -ne 0 ]]; then
          failed_builds+=( "$(basename $i)" )
          failed_builds_paths+=( "$(dirname $i)" )
        fi
      popd
    done
  popd
done

if [[ -z $failed_builds ]]; then
  printf "SUCCESS\n"
  #scp $tito_working_dir/*.rpm $some_repo_somewhere ##<-- rsync would be better
else
  printf "FAILURE\nThe following packages failed to build:\n"
  for f in ${failed_builds[@]}
  do
    printf "${f%.spec}\n"
  done
  printf "\nThese packages can be found in their respective directories:\n"
  for d in ${failed_builds_paths[@]}
  do
    printf "$d\n"
  done
  cat <<EOF
These can be built one by one using the following command in the directory
that contains their .spec file:

tito build \
          --builder mock \
          --builder-arg mock\=$mock_target \
          --rpm \
          --test \
          -o $tito_working_dir

######NOTE: 
### Do not run this script again as it will attempt to rebuild all packages
EOF
fi

printf "All successfull builds can be found in $tito_working_dir\n"
