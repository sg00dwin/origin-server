#!/usr/bin/env python
import sys
import fileinput
import logging
logging.basicConfig(level=logging.CRITICAL)

try:
    from suds.client import Client
    from suds import WebFault
except:
    print "Error: Requires python-suds to be installed"
    print "Take a look at https://fedorahosted.org/suds/"
    sys.exit()

webqa_url = 'http://proxyjavavip.web.qa.ext.intdev.redhat.com/svc/UserService/1?wsdl'

user = Client(webqa_url)

# from here we can do two main things:
# 1) to create complex data types that the server requires: 
#   user.factory.create('complexDataType')
# 2) to call a method defined in the above wsdl:
#   user.service.methodName(params)
# You'll probably never need to do 1, but it's available

# Read in the logins to check from a file or stdin
logins = []
for line in fileinput.input():
    logins.append(line.rstrip())

# Query each of those logins to look for one that isn't found
invalid_logins = []
for login in logins:
    print "Looking up user: " + login
    if user.service.getUserIdByLogin(login):
        print "Found login for user"
    else:
        print "Didn't find the user login, looking up by email"
        try:
            if user.service.findByEmail(login):
                print "Not good - found an invalid login: " + login
                invalid_logins.append(login)
            else:
                print "No email, we're safe"
        except WebFault, e:
            print "No email, we're safe"

print
print "Invalid logins:"
print invalid_logins
