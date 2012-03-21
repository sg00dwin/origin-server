#!/bin/bash

# Source the application environment
for f in ~/.env/*
do
    [ -f "$f" ] && source "$f"
done


# Defaults for sync-gears.  Override these in .env from the configure script
[ -z "$OPENSHIFT_SYNC_GEARS_DIRS" ] && OPENSHIFT_SYNC_GEARS_DIRS=( "repo" "node_modules" "virtenv" ".m2" ".openshift" "deployments" "perl5lib" "phplib" )
[ -z "$OPENSHIFT_SYNC_GEARS_PRE" ] && OPENSHIFT_SYNC_GEARS_PRE=('ctl_all stop')
[ -z "$OPENSHIFT_SYNC_GEARS_POST" ] && OPENSHIFT_SYNC_GEARS_POST=('deploy.sh' 'ctl_all start' 'post_deploy.sh')
[ -z "$OPENSHIFT_SYNC_GEARS_POST" ] && OPENSHIFT_SYNC_GEARS_SSH_KEY="${OPENSHIFT_DATA_DIR}/.ssh/haproxy_id_rsa"
declare -ax OPENSHIFT_SYNC_GEARS_DIRS OPENSHIFT_SYNC_GEARS_PRE OPENSHIFT_SYNC_GEARS_POST 
declare -x OPENSHIFT_SYNC_GEARS_SSH_KEY


if ! [ -f "$OPENSHIFT_SYNC_GEARS_SSH_KEY" ]
then
  echo "ERROR: No ssh key from haproxy" >&2
  exit 100
fi


sshcmd="/usr/bin/ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -F /dev/null -i ${OPENSHIFT_SYNC_GEARS_SSH_KEY}"
rsynccmd="rsync -v --delete-after -az"
export RSYNC_RSH="$sshcmd"


# Manage sync tasks in parallel
GEARSET=()   # TODO, obtan gear list
STDOUTS=()   # Set of outputs
EXITCODES=() # Set of exit codes

for gear in "${GEARSET[@]}"
do
  output=$(mktemp "${OPENSHIFT_GEAR_DIR}/tmp/sync_gears.output.XXXXXXXXXXXXXXXX")
  STDOUTS="${STDOUTS[@]} $output"
  exitcode=$(mktemp "${OPENSHIFT_GEAR_DIR}/tmp/sync_gears.exit.XXXXXXXXXXXXXXXX")
  EXITCODES="${EXITCODES[@]} $output"

  (
    ( 
      set -x -e
      echo "Syncing to gear: $gear @ " $(date)

      TARGET_GEAR_DIR=$($sshcmd "$gear" 'source ~/.env/OPENSHIFT_GEAR_DIR 2>/dev/null; echo $OPENSHIFT_GEAR_DIR')
      if [ $? -ne 0 -o -z "$TARGET_GEAR_DIR" ]
      then
        echo "Failed to get target gear directory"
        exit 128
      fi

      # Prepare remote gear for new content
      for rpccall in "${OPENSHIFT_SYNC_GEARS_PRE[@]}"
      do
        $sshcmd "$gear" "$rpccall"
      done

      # Push content to remote gear
      for subd in "${OPENSHIFT_SYNC_GEARS_DIRS[@]}"
      do
        if [ -d "${OPENSHIFT_GEAR_DIR}/${subd}" ]
        then
          $rsynccmd "${OPENSHIFT_GEAR_DIR}/${subd}/" "${gear}:${TARGET_GEAR_DIR}/${subd}/"
        fi
      done
      
      # Post-sync calls & start
      for rpccall in "${OPENSHIFT_SYNC_GEARS_POST[@]}"
      do
        $sshcmd "$gear" "$rpccall"
      done

    )
    echo $? > "$exitcode"
  ) >"$output" 2>&1 &

done
wait

# Serialize outputs and exit codes for easier debugging
exc=0
i=0
while [ $i -lt "${#STDOUTS[@]}" ]
do
  cat "${STDOUTS[$i]}"
  pexc=$(cat "${EXITCODES[$i]}")
  echo "Exit code: $pexc"
  if [ "$pexc" != "0" ]; then
    exc=128   # TODO: instead? exc=$(($exc | $pexc))
  fi
  rm -f "${STDOUTS[$i]}" "${EXITCODES[$i]}"
  i=$(($i + 1))
done

exit $exc
