#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

export REPOLIB="$OPENSHIFT_APP_DIR/repo/libs/"
export LOCALSITELIB="$OPENSHIFT_APP_DIR/perl5lib/lib/perl5/"
export PERL5LIB="$REPOLIB:$LOCALSITELIB"