#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Run when jenkins is not being used or run when inside a build
export PERL5LIB="${OPENSHIFT_REPO_DIR}libs:~/${OPENSHIFT_APP_NAME}/perl5lib"

if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found!  Re-building perl modules" 1>&2
    rm -rf "${OPENSHIFT_APP_NAME}/perl5lib/"* ~/.cpan/*
fi

if `echo $OPENSHIFT_APP_DNS | grep -q .stg.rhcloud.com` || `echo $OPENSHIFT_APP_DNS | grep -q .dev.rhcloud.com`
then 
    LOCALMIRROR="http://mirror1.stg.rhcloud.com/mirror/perl/CPAN/"
else 
    LOCALMIRROR="http://mirror1.prod.rhcloud.com/mirror/perl/CPAN/"
fi

if [ -f ${OPENSHIFT_REPO_DIR}deplist.txt ]
then
    for f in $( (find ${OPENSHIFT_REPO_DIR} -type f | grep -e "\.pm$\|.pl$" | xargs /usr/lib/rpm/perl.req | awk '{ print $1 }' | sed 's/^perl(\(.*\))$/\1/'; cat ${OPENSHIFT_REPO_DIR}deplist.txt ) | sort | uniq)
    do
        if [ -n "$LOCALMIRROR" ]
        then
            cpanm --mirror $LOCALMIRROR -L ~/${OPENSHIFT_APP_NAME}/perl5lib "$f"
        else
            cpanm -L ~/${OPENSHIFT_APP_NAME}/perl5lib "$f"
        fi
    done
fi

# Run user build
user_build.sh
