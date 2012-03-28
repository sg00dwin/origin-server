#!/bin/bash
tmp_file=$(mktemp)

function clean_exit()
{
    echo "Cleaning up and exiting"
    echo "CSV Stored in /tmp/run.csv"
    rm -f $tmp_file
    exit 0
}

trap clean_exit SIGINT SIGTERM

function run_test()
{
    ab -r -c 300 -t 10 -e /tmp/info.csv http://hatest-mmcgrath930.dev.rhcloud.com/ > $tmp_file 2> /dev/null
    
}

function print_header()
{
    echo "run,document_length,concurrency,time_for_tests,complete_requests,failed_requests,write_errors,total_bytes_transferred,html_transferred,requests_per_second,time_per_request_mean,time_per_request_concurrent_mean,transfer_rate,served_50,served_66,served_75,served_80,served_90,served_95,served_98,served_99,served_100" > /tmp/run.csv
    head -n1 /tmp/run.csv
}

function print_results()
{
    time=$(date +%H:%M:%S)
    document_length=$( awk '/Document Length/{ print $3 }' $tmp_file)
    concurrency=$( awk '/Concurrency Level/{ print $3 }' $tmp_file)
    time_for_tests=$( awk '/Time taken for tests/{ print $5 }' $tmp_file)
    complete_requests=$( awk '/Complete requests/{ print $3 }' $tmp_file)
    failed_requests=$( awk '/Failed requests/{ print $3 }' $tmp_file)
    write_errors=$( awk '/Write errors/{ print $3 }' $tmp_file)
    total_bytes_transferred=$( awk '/Total transferred/{ print $3 }' $tmp_file)
    html_transferred=$( awk '/HTML transferred/{ print $3 }' $tmp_file)
    requests_per_second=$( awk '/Requests per second/{ print $4 }' $tmp_file)
    time_per_request_mean=$( awk '/Time per request.*\(mean\)/{ print $4 }' $tmp_file)
    time_per_request_concurrent_mean=$( awk '/Time per request.*concurrent/{ print $4 }' $tmp_file)
    transfer_rate=$( awk '/Transfer rate/{ print $3 }' $tmp_file)

    served_50=$( awk '/50%/{ print $2 }' $tmp_file)
    served_66=$( awk '/66%/{ print $2 }' $tmp_file)
    served_75=$( awk '/75%/{ print $2 }' $tmp_file)
    served_80=$( awk '/80%/{ print $2 }' $tmp_file)
    served_90=$( awk '/90%/{ print $2 }' $tmp_file)
    served_95=$( awk '/95%/{ print $2 }' $tmp_file)
    served_98=$( awk '/98%/{ print $2 }' $tmp_file)
    served_99=$( awk '/99%/{ print $2 }' $tmp_file)
    served_100=$( awk '/100%/{ print $2 }' $tmp_file)
    echo "$time,$document_length,$concurrency,$time_for_tests,$complete_requests,$failed_requests,$write_errors,$total_bytes_transferred,$html_transferred,$requests_per_second,$time_per_request_mean,$time_per_request_concurrent_mean,$transfer_rate,$served_50,$served_66,$served_75,$served_80,$served_90,$served_95,$served_98,$served_99,$served_100" >> /tmp/run.csv
    tail -n1 /tmp/run.csv
}

print_header
for f in `seq 1 60`
do
    run_test 
    print_results
done

clean_exit
