#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

/usr/bin/mysqldump -h $OPENSHIFT_DB_HOST -P $OPENSHIFT_DB_PORT -u $OPENSHIFT_DB_USERNAME --password="$OPENSHIFT_DB_PASSWORD" --all-databases --add-drop-table | /bin/gzip -v > $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz

if [ ! ${PIPESTATUS[0]} -eq 0 ]
then
    echo 1>&2
    echo "WARNING!  Could not dump mysql!  Continuing anyway" 1>&2
    echo 1>&2
    /bin/rm -rf $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz
    /bin/cp ~/.env/OPENSHIFT_DB_PASSWORD ~/.env/OPENSHIFT_DB_USERNAME
fi
