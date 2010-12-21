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
    echo -e $1 1>&2
    exit
}

function print_help {
    echo "Usage: $0"
    echo "Create a new LAMP libra project."
    echo
    echo "  -u username             Your libra username"
    echo "  -a application_name     Application name"
    echo "  -n new_repo_path        Path to new git repo"
    echo "  -y                      Pre-agree to conditions (don't prompt)"
    echo "  -d                      (optional: debug)"
    exit 1
}

while getopts 'u:a:n:dy' OPTION
do
    case $OPTION in
        u) username=$OPTARG
        ;;
        a) application=$OPTARG
        ;;
        n) new_repo_path=$OPTARG
        ;;
        y) pre_agree=$OPTARG
        ;;
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

if ( [ -z "$username" ] || [ -z "$application" ] || [ -z "$new_repo_path" ])
then
    print_help
fi

if [ -z "$pre_agree" ]
then
    echo -n "NOTICE: This is pre-alpha destructionware.  It is not tested, it
might break at any time.  While we'll generally leave it running, there is no
attempt at data protection or downtime minimization.  This is just a proof
of concept, do not store anything important here.

Thar be dragons this way.

Rules/Terms:
1) Don't put anything important here.
2) Know we won't be protecting data in any way and may arbitrarly destroy it
3) The service will go up and down as we are developing it, which may be a lot
4) We'll be altering your ~/.ssh/config file a bit, should be harmless.
5) Bugs should be sent to the libra team
6) This entire service may vanish as this is just a proof of concept.

Do you agree to the rules and terms? (y/n): "
    read agree
    if [ $agree != 'y' ]
    then
        echo "Sorry this won't work for you, keep tabs for future updates"
        exit 5
    fi
fi

echo
echo "Remember: this is pre-alpha destructionware.  Let #libra know of any bugs you find"
echo
echo "Creating local application space"
[ -d $new_repo_path ] && quit "$new_repo_path already exists!\nPlease specify a new path"
mkdir -p $new_repo_path
pushd $new_repo_path
git init
cat <<EOF >> $new_repo_path/.git/config
[remote "libra"]
    url = ssh://${username}@${application}.${username}.libra.mmcgrath.net/var/lib/libra/${username}/git/${application}.git/
EOF
cat <<EOF > index.php
Place your application here
EOF
cat <<EOF > health_check.php
<?php
print 1;
?>
EOF
git add *
git commit -a -m "Initial libra creation"
popd

echo "Creating remote application space"
curl --verbose -f --data-urlencode "username=${username}" --data-urlencode "application=${application}" "http://$LI_SERVER/create_http.php" > /tmp/$USER_libra_debug.txt 2>&1 || quit "Creation failed.  See /tmp/libra_debug.txt for more information"

#
# Check or add new host to ~/.ssh/config
#

if grep -q ${application}.${username}.libra.mmcgrath.net ~/.ssh/config
then
    echo "Found ${application}.${username}.libra.mmcgrath.net in ~/.ssh/config."
else
    echo "Adding ${application}.${username}.libra.mmcgrath.net to ~/.ssh/config"
    cat <<EOF >> ~/.ssh/config
# Added by libra app on $(date)
Host ${application}.${username}.libra.mmcgrath.net
    User ${username}
    IdentityFile ~/.ssh/libra_id_rsa

EOF
fi

# 
# Push initial repo upstream (contains index and health_check)
#

pushd $new_repo_path
echo "Doing initial test push"
git push libra master
popd

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
    curl -s -f http://${application}.${username}.libra.mmcgrath.net/health_check.php > /dev/null
    exit_code=$?
    case $exit_code in
    0)
        echo "Success!  Your application is now available at:"
        echo
        echo "      http://${application}.${username}.libra.mmcgrath.net/"
        echo
        exit 1
    ;;
    22)
        echo "Connection success, but application not yet available.  Tryin again"
    ;;
    *)
        echo "Attempt unknown"
    ;;
    esac
    sleep_time=$(($sleep_time * 2))
done
