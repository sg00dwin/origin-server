#!/bin/bash
#
# misc/rebuild_drupal_pkgs.sh
#
#   This script will build all OpenShift drupal packages for community
# 
# Author: Adam Miller <admiller@redhat.com>

f_ctrl_c() {
  printf "\n*** Exiting ***\n"
  exit $?
}
     
# trap int (ctrl-c)
trap f_ctrl_c SIGINT


f_usage() {
cat <<EOF
Usage: ./misc/rebuild_drupal_pkgs.sh  (from inside the li repo)

NOTE: 
  - You will need brew and tito configured.
  - Will also need rpmdevtools installed, will error otherwise.
  - Depends on the directory hierarchy of li

EOF
  exit 1
}

# Slight sanity checking
rpmdev-bumpspec -v > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  printf "ERROR: rpmdevtools not installed; rpmdev-bumpspec not found\n"
  f_usage
fi
tito report -h  > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  printf "ERROR: tito not found; \n"
  f_usage
fi
brew -h  > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  printf "ERROR: brew not found; \n"
  f_usage
fi

if ! [[ -d ./drupal ]]; then
  printf "ERROR: ../drupal directory not found;\n"
  f_usage
fi


for dir in ./drupal/*
do
  pushd $dir > /dev/null;
    rpmdev-bumpspec -c "- Bump spec for mass drupal rebuild" *.spec
    git add *.spec; 
    git commit -m "bumping spec for drupal mass rebuild"
    tito tag --keep-version --no-auto-changelog
  popd > /dev/null;
done
    
git fetch --tags && git pull && git push origin master && git push --tags
rm -fr /tmp/tito/* # This is dirty but keeps from colliding

printf "y\nn" > /tmp/answerfile
for dir in ./drupal/*
do
  pushd $dir > /dev/null;
    tito release brew < /tmp/answerfile
  popd > /dev/null;
done

