#!/bin/bash


if [ -f $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz ]
then
    /bin/zcat $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz | /usr/bin/mysql -h $OPENSHIFT_DB_HOST -P $OPENSHIFT_DB_PORT -u $OPENSHIFT_DB_USERNAME --password="$OPENSHIFT_DB_PASSWORD"
    if [ ! ${PIPESTATUS[1]} -eq 0 ]
    then
        echo 1>&2
        echo "Error: Could not import MySQL Database!  Continuing..." 1>&2
        echo 1>&2
    fi
    /bin/rm -rf $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz
else
    echo "Mysql restore attempted but no dump found!" 1>&2
    echo "$OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz does not exist" 1>&2
fi
