#!/usr/bin/python
import os, sys
print "simple: pid = %d: %s" % (os.getpid(), sys.version.replace("\n", ""))
