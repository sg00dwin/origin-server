#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

/bin/rm -rf $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz $OPENSHIFT_DATA_DIR/OPENSHIFT_DB_PASSWORD $OPENSHIFT_DATA_DIR/OPENSHIFT_DB_USERNAME
