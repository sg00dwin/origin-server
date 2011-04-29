#!/bin/sh

for i in {1..10}
do
 ./batch_register -p -c 10 -n 100 -d > ~/Desktop/users$i
done
