#!/bin/bash

libra_server=$1

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

export PERL5LIB="${OPENSHIFT_REPO_DIR}libs:~/${OPENSHIFT_APP_NAME}/perl5lib"

if [ -f ${OPENSHIFT_REPO_DIR}deplist.txt ]
then
    for f in $( (find ${OPENSHIFT_REPO_DIR} -type f | grep -e "\.pm$\|.pl$" | xargs /usr/lib/rpm/perl.req | awk '{ print $1 }' | sed 's/^perl(\(.*\))$/\1/'; cat ${OPENSHIFT_REPO_DIR}deplist.txt ) | sort | uniq)
    do
        cpanm -L ~/${OPENSHIFT_APP_NAME}/perl5lib "$f"
    done
fi

# Run build
user_build.sh

# Start the app
start_app.sh

nurture_app_push.sh $libra_server