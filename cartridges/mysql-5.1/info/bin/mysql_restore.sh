#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done


if [ -f $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz ]
then
    OLD_IP=$(/bin/cat $OPENSHIFT_DATA_DIR/mysql_db_host)
    # Prep the mysql database
    (
        /bin/zcat $OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz
        echo "; use mysql; update user set Host='$OPENSHIFT_DB_HOST' where Host='$OLD_IP'; update user set Password='$OPENSHIFT_DB_PASSWORD' where User='$OPENSHIFT_DB_USERNAME';"
    ) | /usr/bin/mysql -h $OPENSHIFT_DB_HOST -P $OPENSHIFT_DB_PORT -u $OPENSHIFT_DB_USERNAME --password="$OPENSHIFT_DB_PASSWORD"
    if [ ! ${PIPESTATUS[1]} -eq 0 ]
    then
        echo 1>&2
        echo "Error: Could not import MySQL Database!  Continuing..." 1>&2
        echo 1>&2
    fi
    $OPENSHIFT_DB_MYSQL_51_DUMP_CLEANUP
else
    echo "Mysql restore attempted but no dump found!" 1>&2
    echo "$OPENSHIFT_DATA_DIR/mysql_dump_snapshot.gz does not exist" 1>&2
fi
