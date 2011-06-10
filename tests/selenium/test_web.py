#!/usr/bin/python

import sys
import subprocess
from optparse import OptionParser
import commands

host="192.168.122.1"
url="https://stg.openshift.redhat.com"
port="5557"
browser="firefox /usr/lib64/firefox-3.6/firefox"
confirm_url="https://stg.openshift.redhat.com/app/email_confirm_express?key=sB4oQyylcO7pREpvnxQH34yeuz17l4cLberX1xUh&emailAddress=xtian%2B161%40redhat.com"
toregister_userlist=['xtian+cc0@redhat.com']
new_userlist=['libra-test+stage93915447@redhat.com', 'libra-test+stage76127332@redhat.com', 'libra-test+stage53991273@redhat.com', 'libra-test+stage41844479@redhat.com', 'libra-test+stage19243334@redhat.com']
old_userlist=['xtian+1@redhat.com']

def conf_file_parser(conf_file):
    new_context=""
    myfile = open(conf_file,'r')
    line=myfile.readline()
    #line=myfile.readline().strip('\n')
    while line != """""":
        #line=myfile.readline().strip('\n')
        line=line.replace('"','\\"')
        line=line.replace("'","\\'")
        new_context=new_context+line
        #print "---%s---" %(line)
        line=myfile.readline()
    myfile.close

    tmp_file = open(conf_file,'w')
    tmp_file.write(new_context)
    tmp_file.close
    return conf_file



if __name__ == "__main__":
    
    cmd="./register_random  -d 2>debug1.log"
    (ret,output)=commands.getstatusoutput(cmd)
    print output
    new_userlist = [output]
    for i in range(3):
        (ret,output)=commands.getstatusoutput(cmd)
        print output
        new_userlist = new_userlist + [output]

    cmd="./register_random  -c  -d 2>debug2.log"
    (ret,output)=commands.getstatusoutput(cmd)
    print output
    new_userlist = new_userlist + [output.split("\n")[0]]
    confirm_url = output.split("\n")[1]
    
    '''
    print "----------Default value---------"
    print "host=%s" %(host)
    print "url=%s" %(url)
    print "port=%s" %(port)
    print "browser=%s" %(browser)
    print "confirm_url=%s" %(confirm_url)
    print "toregister_userlist=%s" %(toregister_userlist)
    print "new_userlist=%s" %(new_userlist)
    print "old_userlist=%s" %(old_userlist)
    print ""
    '''
    if len(sys.argv) < 1:
        print """usage: --host=<ip_address> --url=<url> --port=<port> --browser=<browser> --confirm_url=<confirm_url> --toregister_userlist=<"item1,item2,...,itemN"> --new_userlist=<"item1,item2,...,itemN"> --old_userlist=<"item1,item2,...,itemN">"""
        sys.exit(1)

    parser = OptionParser()
    parser.add_option("--host", dest="host",
                       help="host name")
    parser.add_option("--url", dest="url",
                       help="url link")
    parser.add_option("--port", dest="port",
                       help="port number")
    parser.add_option("--browser", dest="browser",
                       help="browser name")
    parser.add_option("--confirm_url", dest="confirm_url",
                       help="confirm url link")
    parser.add_option("--toregister_userlist", dest="toregister_userlist",
                       help="toregister_user List array")
    parser.add_option("--new_userlist", dest="new_userlist",
                       help="new_userlist List array")
    parser.add_option("--old_userlist", dest="old_userlist",
                       help="old_userlist List array")

    (options, args) = parser.parse_args()

    if options.host != None: host = options.host
    if options.url != None: url = options.url
    if options.port != None: port = options.port
    if options.browser != None: browser = options.browser
    if options.confirm_url != None: confirm_url = options.confirm_url    
    if options.toregister_userlist != None: 
        toregister_userlist = options.toregister_userlist.split(',')
        #print toregister_userlist
        #print type(toregister_userlist)
    if options.new_userlist != None:
        new_userlist = options.new_userlist.split(' ')
    if options.old_userlist != None:
        old_userlist = options.old_userlist.split(',')

    print "------Current value-------"
    print "host=%s" %(host)
    print "url=%s" %(url)
    print "port=%s" %(port)
    print "browser=%s" %(browser)
    print "confirm_url=%s" %(confirm_url)
    print "toregister_userlist=%s" %(toregister_userlist)
    print "new_userlist=%s" %(new_userlist)
    print "old_userlist=%s" %(old_userlist)
    print ""

    context="""host="%s"
url="%s"
port="%s"
browser="%s"
confirm_url="%s"
toregister_userlist=%s
new_userlist=%s
old_userlist=%s
""" %(host,url,port,browser,confirm_url,toregister_userlist,new_userlist,old_userlist)


    cmd="uuidgen"
    (ret,output)=commands.getstatusoutput(cmd)
    tmp_file_name="my_conf_" + output + ".tmp"
    f=open(tmp_file_name, 'w')
    f.write(context)
    f.close()

    my_conf = conf_file_parser(tmp_file_name)
    ret=subprocess.call(["sh","run_scripts.sh", my_conf])
    
    sys.exit(0)

