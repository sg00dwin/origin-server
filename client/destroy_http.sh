#!/bin/bash
# Copyright © 2010 Mike McGrath All rights reserved
# Copyright © 2010 Red Hat, Inc. All rights reserved

# This copyrighted material is made available to anyone wishing to use, modify,
# copy, or redistribute it subject to the terms and conditions of the GNU
# General Public License v.2.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY expressed or implied, including the
# implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.  You should have
# received a copy of the GNU General Public License along with this program;
# if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301, USA. Any Red Hat trademarks that are
# incorporated in the source code or documentation are not subject to the GNU
# General Public License and may only be used or replicated with the express
# permission of Red Hat, Inc.

set -e

LI_SERVER='li.mmcgrath.libra.mmcgrath.net'

function quit {
    echo $1 1>&2
    exit
}

function print_help {
    echo "Usage: $0"
    echo "Destroy an existing LAMP libra project."
    echo
    echo "  -u username"
    echo "  -a application_name"
    echo "  -d (optional: debug)"
    exit 1
}

while getopts 'u:a:d' OPTION
do
    case $OPTION in
        u) username=$OPTARG
        ;;
        a) application=$OPTARG
        ;;
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$username" ] || [ -z "$application" ] )
then
    print_help
fi

echo "Destroying application space: ${application}"

TMPDIR=$(mktemp -d --suffix=libra)
curl --verbose -f --data-urlencode "username=${username}" --data-urlencode "application=${application}" "http://$LI_SERVER/destroy_http.php" > $TMPDIR/debug.log 2>&1 || quit "Creation failed.  See $TMPDIR/debug.log for more information"
sleep_time=2
attempt=0

#
# Test several times, doubling sleep time between attempts.
#

while [ $sleep_time -lt 65 ]
do
    echo "sleeping ${sleep_time}s"
    sleep ${sleep_time}
    attempt=$(($attempt+1))
    echo "Testing attempt: $attempt"
    curl -s -f http://${application}.${username}.libra.mmcgrath.net/health_check.php | grep -q -e '^1$' ||:
    exit_codes=${PIPESTATUS[*]}
    grep_exit=$(echo $exit_codes | awk '{ print $2 }')
    exit_code=$(echo $exit_codes | awk '{ print $1 }')
    case $exit_code in
    0)
        if [ ! $grep_exit = '0' ]
        then
            echo "Remove successful!  Confirm removal at:"
            echo
            echo "      http://${application}.${username}.libra.mmcgrath.net/"
            echo
            rm -rf $TMPDIR
            exit 1
        else
            echo "Connection success, health_check failed: Confirm removal at:"
            echo
            echo "      http://${application}.${username}.libra.mmcgrath.net/"
            echo
            rm -rf $TMPDIR
            exit 1
        fi
    ;;
    6)
        echo "Application removed!  Confirm at:"
        echo
        echo "http://${application}.${username}.libra.mmcgrath.net/"
        echo
    ;;
    *)
        echo "Attempt unknown"
    ;;
    esac
    sleep_time=$(($sleep_time * 2))
done
