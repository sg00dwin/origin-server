#!/bin/sh

mkdir ~/Desktop/data

for i in {1..100}
do
 ./batch_register -p -c 10 -n 10 -d > ~/Desktop/data/$i
done

cat ~/Desktop/data/* > ~/Desktop/output
