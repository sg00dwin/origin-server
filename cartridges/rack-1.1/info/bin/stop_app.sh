# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

echo "Stopping application..."
httpd_pid=`cat ~/${OPENSHIFT_APP_NAME}/run/httpd.pid 2> /dev/null`
~/${OPENSHIFT_APP_NAME}/${OPENSHIFT_APP_NAME}_ctl.sh stop
for i in {1..20}
do
    if `ps --pid $httpd_pid > /dev/null 2>&1` || `pgrep Passenger* > /dev/null 2>&1`
    then
        echo "Waiting for stop to finish"
        sleep 3
    else
        break
    fi
done
echo "Done"