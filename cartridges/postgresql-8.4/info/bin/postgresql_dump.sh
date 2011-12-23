#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=${CART_DIR:=/usr/libexec/li/cartridges}
CART_INFO_DIR=$CART_DIR/embedded/postgresql-8.4/info
source ${CART_INFO_DIR}/lib/util

start_postgres_as_user

/usr/bin/pg_dumpall -h $OPENSHIFT_DB_HOST -p $OPENSHIFT_DB_PORT -u $OPENSHIFT_DB_USERNAME | /bin/gzip -v > $OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz

if [ ! ${PIPESTATUS[0]} -eq 0 ]
then
    echo 1>&2
    echo "WARNING!  Could not dump PostgreSQL databases!  Continuing anyway" 1>&2
    echo 1>&2
    /bin/rm -rf $OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz
fi
