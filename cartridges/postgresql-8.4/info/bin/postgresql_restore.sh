#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done


if [ -f $OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz ]
then
	CART_DIR=${CART_DIR:=/usr/libexec/li/cartridges}
	CART_INFO_DIR=$CART_DIR/embedded/postgresql-8.4/info
	source ${CART_INFO_DIR}/lib/util

    start_postgres_as_user

    # Restore the PostgreSQL databases
    /bin/zcat $OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz |  \
         /usr/bin/psql -h $OPENSHIFT_DB_HOST -p $OPENSHIFT_DB_PORT -W -u $OPENSHIFT_DB_USERNAME
    if [ ! ${PIPESTATUS[1]} -eq 0 ]
    then
        echo 1>&2
        echo "Error: Could not import PostgreSQL Database!  Continuing..." 1>&2
        echo 1>&2
    fi
    $OPENSHIFT_DB_POSTGRESQL_84_DUMP_CLEANUP

else
    echo "PostgreSQL restore attempted but no dump found!" 1>&2
    echo "$OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz does not exist" 1>&2
fi
