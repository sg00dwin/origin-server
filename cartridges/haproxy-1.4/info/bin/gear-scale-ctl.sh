#!/bin/bash

if [ -f /etc/libra/node.conf ]; then
  . /etc/libra/node.conf
fi

function usage {
  echo 1>&2
  echo "Usage: add-gear -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <domain> [-h|--host <hostname>]" 1>&2
  echo 1>&2
  echo "Usage: remove-gear -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <domain> [-h|--host <hostname>]" 1>&2
  echo 1>&2
  echo "Usage: create-scalable-app -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <domain> -t|--type <cartridge type> [-h|--host <hostname>]" 1>&2
  exit 1
}

if ! options=$(getopt -u -o h:l:p:a:n:t: -l host:rhlogin:password:app:namespace:type: -- "$@"); then
  # getopt prints error message
  usage
fi
set -- $options

while [ $# -gt 0 ]; do
  case "$1" in
    -a|--app)       app="$2"; shift;;
    -h|--host)      host="$2"; shift;;
    -l|--rhlogin)   user="$2"; shift;;
    -p|--password)  password="$2"; shift;;
    -n|--namespace) namespace="$2"; shift;;
    -t|--type)      type="$2"; shift;;
    --) shift; break;;
    -*)usage ;;
    *) break;;
  esac
  shift
done

# default to localhost if nothing else provided
: ${host:=${libra_server:-'localhost'}}

if [ -z "$app" -o -z "$host" -o -z "$user" -o -z "$password" -o -z "$namespace" ]; then
  usage
fi

create_url="curl -k -X POST -H \"Accept: application/xml\" --user \"$user:$password\" https://$host/broker/rest/domains/$namespace/applications"
scale_url="$create_url/$app/events"

set -x
case "$0" in
  */create-scalable-app)
                  [ -z "$type" ] && usage
                  eval "$create_url -d name=$app -d cartridge=$type -d scale=true"
                  ;;
  */add-gear)     eval "$scale_url -d event=scale-up" ;;
  */remove-gear)  eval "$scale_url -d event=scale-down" ;;
  *) usage ;;
esac
set +x

