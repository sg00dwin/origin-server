#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done


if [ -f "$OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz" ]
then
	CART_DIR=${CART_DIR:=/usr/libexec/li/cartridges}
	CART_INFO_DIR=$CART_DIR/embedded/postgresql-8.4/info
	source ${CART_INFO_DIR}/lib/util

    start_postgresql_as_user

    old_dbname=$OPENSHIFT_APP_NAME
    old_dbuser=$OPENSHIFT_APP_UUID
    [ -f "$OPENSHIFT_DATA_DIR/postgresql_dbname" ] &&  old_dbname=$(cat "$OPENSHIFT_DATA_DIR/postgresql_dbname")
    [ -f "$OPENSHIFT_DATA_DIR/postgresql_dbuser" ] &&  old_dbuser=$(cat "$OPENSHIFT_DATA_DIR/postgresql_dbuser")

    # Restore the PostgreSQL databases
    rexp="^\s*\(DROP\|CREATE\)\s*DATABASE\s*$old_dbname"
    pargz="--username=$OPENSHIFT_DB_USERNAME --host=$OPENSHIFT_DB_HOST"

    /bin/zcat $OPENSHIFT_DATA_DIR/postgresql_dump_snapshot.gz |        \
        sed "s#$rexp#\\1 DATABASE $OPENSHIFT_APP_NAME#g;               \
             s#\\connect $old_dbname#\\connect $OPENSHIFT_APP_NAME#g;  \
             s#$old_dbuser#$OPENSHIFT_APP_UUID#g" |                    \
        PGPASSWORD="$OPENSHIFT_DB_PASSWORD" /usr/bin/psql $pargz -d postgres

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
