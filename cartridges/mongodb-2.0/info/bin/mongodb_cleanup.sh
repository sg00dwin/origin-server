#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

#/bin/rm -rf $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz $OPENSHIFT_DATA_DIR/mysql_db_host
echo "NOT YET IMPLEMENTED!" 2>&1
exit 5
