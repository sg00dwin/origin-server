#!/bin/bash
#
# misc/tito_build_oss_fedora.sh
#
#   This script will build all opensource components using tito and mock on a 
#   local machine in order to create a "cleanly built" repository. Attempting
#   to mimic having an actual build system the best we can.
# 
# Author: Adam Miller <admiller@redhat.com>

f_ctrl_c() {
  printf "\n*** Exiting ***\n"
  exit $?
}
     
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

# "Global" variables
sibling_dirs=( "os-client-tools" "crankcase" )
sync_only=""
remote_repo="mirror1.stg.rhcloud.com/libra"
declare -a failed_builds
declare -a failed_builds_paths

f_usage() {
cat <<EOF
Usage: misc/tito_build_oss_fedora.sh [options] [build_target]
    options: build, sync
    build_target: mock config name, ex: fedora-16

NOTE: example mock build target of fedora-16 will build both i386 and x86_64
EOF
  exit 1
}

# Slight sanity checking
if [[ -n "$1" ]]; then
  if [[ "$1" == "sync" ]]; then
    sync_only="true"
  fi
  if [[ -n "$2" ]]; then
    mock_target="$2"
    tito_working_dir=/tmp/tito/build_oss_fedora/$2
  else
    printf "ERROR: Invalid argument or no argument given\n"
    f_usage
  fi
else
  f_usage
fi

f_sync() {

  printf "Staging repo directory structure ...\n"
  mkdir -p $tito_working_dir/reposync/{SRPMS,i386,x86_64}
  mv $tito_working_dir/*.src.rpm $tito_working_dir/reposync/SRPMS/
  cp $tito_working_dir/*.noarch.rpm $tito_working_dir/reposync/x86_64/
  cp $tito_working_dir/*.noarch.rpm $tito_working_dir/reposync/i386/
  printf "Syncing now ...\n"
  rsync -aHv \
    --dry-run \
    --delete-after \
    --progress \
    --no-g \
    --omit-dir-times \
    --chmod=Dug=rwX \
    $tito_working_dir/reposync/* \
    root@mirror1.prod.rhcloud.com:/srv/pub/crankcase/nightly/$mock_target/
  #scp $tito_working_dir/*.rpm $some_repo_somewhere ##<-- rsync would be better
  printf "Complete!\n"

}

if [[ -n "$sync_only" ]]; then
  echo "SYNC ONLY: $tito_working_dir"
  f_sync
  exit 0
fi

# check mock stuff 
if ! mock --version &> /dev/null; then
  printf "ERROR: mock not installed or not in current \$PATH\n"
  exit 2
fi
if [[ ! -f /etc/mock/${mock_target}-x86_64.cfg ]]; then
  printf "ERROR: $mock_target is an invalid mock build target\n"
  printf "\tNo /etc/mock/${mock_target}-x86_64.cfg found\n"
  exit 3
elif [[ ! -f /etc/mock/${mock_target}-i386.cfg ]]; then
  printf "ERROR: $mock_target is an invalid mock build target\n"
  printf "\tNo /etc/mock/${mock_target}-i386.cfg found\n"
  exit 3
fi

# make sure tito is installed
if ! tito build --help &> /dev/null; then
  printf "ERROR: tito not installed or not in current \$PATH\n"
  exit 4
fi

# check system arch, we only need to build once since all packages are noarch
if grep x86_64 <(uname -a) &> /dev/null; then
  build_arch="x86_64"
else
  build_arch="i386"
fi

# clean the old build working dir
if [[ -d $tito_working_dir ]]; then
  rm -fr $tito_working_dir
fi
mkdir -p $tito_working_dir

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
          --builder-arg mock\=${mock_target}-${build_arch} \
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
          --builder-arg mock\=${mock_target}-${build_arch} \
          --rpm \
          --test \
          -o $tito_working_dir

######NOTE: 
### Do not run this script again with 'build' arg as it will attempt to 
### rebuild all packages as well as overwrite all already built packages

Once the individual builds are complete, they may be sync'd to the repo
with the 'sync' option to this script.
EOF
fi

printf "All successfull builds can be found in $tito_working_dir\n"
