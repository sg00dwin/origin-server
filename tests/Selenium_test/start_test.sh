#!/bin/sh

if [ "$#" != "4" ]; then
  echo -e "Usage of this script:\t$0 seleniumhost(eg:192.168.122.1)  testurl(https://stg.openshift.redhat.com) seleniumport(5557) browsertype(*firefox) \n"
  exit 1
else
  rm -rf ./result
  New_userlist=(libra-test+stage93915447@redhat.com libra-test+stage76127332@redhat.com libra-test+stage53991273@redhat.com libra-test+stage41844479@redhat.com libra-test+stage19243334@redhat.com)
  confirm_link="https://stg.openshift.redhat.com/app/email_confirm_express?key=sB4oQyylcO7pREpvnxQH34yeuz17l4cLberX1xUh&emailAddress=xtian%2B161%40redhat.com"

  for i in {0..3}
  do 
  ./register_random  -p -d >>./result
  done
  ./register_random -c  -p -d >>./result
   j=0
   while read line;
   do
   if  [ $j -lt 5 ];then
     New_userlist[$j]="$line";
     ((j+=1));
   elif [ $j -eq 5 ];then
     confirm_link="$line";
     ((j+=1));
   fi

   done <./result

   echo $confirm_link
   echo 
   echo ${New_userlist[*]}

   echo "Start to test"

   python ./test_web.py  --host=$1 --url=$2 --port=$3 --browser="$4" --confirm_url=$confirm_link --new_userlist="${New_userlist[*]}"
fi












