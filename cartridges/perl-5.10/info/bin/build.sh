#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

# Run when jenkins is not being used or run when inside a build
export PERL5LIB="${OPENSHIFT_REPO_DIR}libs:~/${OPENSHIFT_APP_NAME}/perl5lib"

if `echo $OPENSHIFT_APP_DNS | grep -q stg.rhcloud.com` ; then 
	LOCALMIRROR="http://mirror1.stg.rhcloud.com/mirror/perl/CPAN/"
else 
	LOCALMIRROR="http://mirror1.prod.rhcloud.com/mirror/perl/CPAN/"
fi

if [ -f ${OPENSHIFT_REPO_DIR}deplist.txt ]
then
    for f in $( (find ${OPENSHIFT_REPO_DIR} -type f | grep -e "\.pm$\|.pl$" | xargs /usr/lib/rpm/perl.req | awk '{ print $1 }' | sed 's/^perl(\(.*\))$/\1/'; cat ${OPENSHIFT_REPO_DIR}deplist.txt ) | sort | uniq)
    do
        cpanm --mirror $LOCALMIRROR -L ~/${OPENSHIFT_APP_NAME}/perl5lib "$f"
    done
fi

# Run user build
user_build.sh
