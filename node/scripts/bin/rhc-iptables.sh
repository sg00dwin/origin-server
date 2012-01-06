#!/bin/bash

#
# Create iptables rules for application compartmentalization.
#

UID_BEGIN=500
UID_END=12700
UTABLE="rhc-app-table"

DEBUG=""
SYSCONFIG=""

function help {
  cat <<EOF >&2
Usage: $0 [ -h ] [ -i | -n | -s ] [ -b UID ] [ -e UID ] [ -t name ]

    Basic options:
    -h       Print this message and exit.

    Output/execution type
    -i       Run iptables (default mode)
    -n       Print what would be done instead of calling iptables.
    -s       Print output suitable for /etc/sysconfig/iptables.

    Less common options that must remain consistent across invocation
    -b UID   Beginning UID.  (default: $UID_BEGIN)
    -e UID   Ending UID.  (default: $UID_END)
    -t name  Table name (default: $UTABLE)
EOF
}

while getopts ':hinsb:e:t:' opt; do
  case $opt in
    'h')
      help
      exit 0
      ;;
    'i')
      DEBUG=""
      SYSCONFIG=""
      ;;
    'n')
      DEBUG=1
      ;;
    's')
      SYSCONFIG=1
      ;;
    'b')
      UID_BEGIN="${OPTARG}"
      ;;
    'e')
      UID_END="${OPTARG}"
      ;;
    't')
      UTABLE="${OPTARG}"
      ;;
    '?')
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    ':')
      echo "Option requires argument: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Test combinations of arguments for compatibility
if [ "${DEBUG}" = "1" -a "${SYSCONFIG}" = "1" ]; then
  echo "Debug (-n) and Sysconfig (-s) are mutually exclusive." >&2
  exit 1
fi

function iptables {
  if [ "${SYSCONFIG}" ]; then
    echo "$@"
  elif [ "${DEBUG}" ]; then
    echo /sbin/iptables "$@"
  else
    /sbin/iptables "$@"
  fi
}

function new_table {
  if [ "${SYSCONFIG}" ]; then
    echo ':'"$1"' - [0:0]'
  else
    iptables -N "$1" || :
    iptables -F "$1"
  fi
}

# Create the table and clear it
new_table ${UTABLE}

# Bottom block is system services, quick bypass
iptables -A OUTPUT -o lo -d 127.0.0.0/25 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -j ACCEPT

# Established connections quickly bypass
iptables -A OUTPUT -o lo -d 127.0.0.0/8 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -m state --state ESTABLISHED,RELATED \
  -j ACCEPT

# New connections with specific uids get checked on the app table.
iptables -A OUTPUT -o lo -d 127.0.0.0/8 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -m state --state NEW \
  -j ${UTABLE}

seq ${UID_BEGIN} ${UID_END} | while read uid; do
  # Logic copied from rhc-ip-prep
  a=$(($uid*128+2130706432))
  net=$(($a>>24 )).$(($(($a%16777216))<<8>>24)).$(($(($a%65536))<<16>>24)).$(($(($a%256))<<24>>24))

  iptables -A ${UTABLE} -d ${net}/25 -m owner --uid-owner $uid -j ACCEPT 
done

# Can't set default policy on a table, set reject at the bottom
iptables -A ${UTABLE} -j REJECT --reject-with icmp-host-prohibited
