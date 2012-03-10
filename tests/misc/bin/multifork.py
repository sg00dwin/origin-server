#!/usr/bin/python
"""
This is a template Python script.  It contains boiler-plate code to define and
handle values needed to run the script.  

Default values are defined in the dictionary "defaults". 
Options are defined in the list "test_options"


"""

# ==============================================================================
#
# MODULES - Libraries needed to perform the task
#
# ==============================================================================



# Prepare default output mechanism
import logging

# Access to getenv for default overrides
import os

# Allow exit control
import sys

# for sleep and debug reports
import time

# Objects for CLI argument processing
from optparse import OptionParser, Option

# =======================
# Add test specific modules here
# =======================

# send and recieve control signals
from signal import signal, alarm, SIG_IGN, SIG_DFL, SIGINT, SIGALRM, SIGTERM

# maxint on 64 bit is too big for sleep.
maxsleep = pow(2, 31) -1

# =============================================================================
#
# OPTIONS - initializing the script execution parameters
#
# =============================================================================

#
# Values to use if no explicit input is given
#
defaults = {
    'debug': False,
    'verbose': False,
    'duration': 5,
    'count': 1,
    'sleep': maxsleep,  # maxint on 64 bit is too big for sleep
    'daemon': False,
    'logfile': None,
    'pidfile': None,
    'format': "text"
}

# Check for default overrides from the environment.
# environment variable names are upper case versions of the default keys.
for key in defaults:
    value = os.getenv("MULTIFORK_" + key.upper())
    if value is not None:
        defaults[key] = value

# Options which all scripts must have.
# Defaults may be inserted from the defaults dictionary defined above.
default_options = (
    Option("-d", "--debug", action="store_true", default=defaults['debug'],
           help="enable debug logging"),
    Option("-v", "--verbose", action="store_true", default=defaults['verbose'],
           help="enable verbose logging"),
    Option("-n", "--dryrun", dest="liverun", action="store_false", 
           default=True,
           help="run logic only, no side effects"),
    Option("-D", "--duration", default=defaults['duration'], type="int",
           help="run for the specified time in seconds"),
    Option("-c", "--count", default=defaults['count'], type="int",
           help="run the number of processes requested"),
    Option("-s", "--sleep", default=defaults['sleep'], type="int",
           help="sleep time for child processes"),
    Option(None, "--daemon", default=defaults['daemon'], action="store_true",
           help="run in the background"),
    Option("-l", "--logfile", default=defaults['logfile'],
           help="where to place log output"),
    Option("-f", "--format", default=defaults['format'], type="choice",
           choices=['text', 'html', 'xml', 'json'],
           help="how to format logging output"),
    Option("-p", "--pidfile", default=defaults['pidfile'],
           help="location of a pid file if running in daemon mode")
)


# CLI arguments specifically for this test.  Add them as needed
test_options = (

)

all_options = default_options + test_options


#
# A header for each log output format
#
headerformat = {
    'text':
"""---- Multifork Report: PID %d----
-------------------------------------------------------------------------------
""",

    'html':
        """<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head>
    <title>Multifork Report</title>
    <style type="text/css">
    table { border-style : solid ; border-width : 2px ; }
    </style>
  </head>
  <body>
    <!-- PID = %d -->
    <h1>Multifork Report</h1>
""",

    'xml':
        """<runreport title="multifork" process="%d">
  <logentries>
""",

    'json':
        """{ "title": "multifork",
  "process": %d,
  "logs": [
"""
    }

# write the invocation/runtime parameters and run context information
introformat = {
    'text': 
    """Daemon:   %s
Duration: %d seconds
Count:    %d children
Sleep:    %d seconds
Log File: %s
PID File: %s
--------------------------------------------------------------------------------
""",

    'html':
       """<table class="summary">
  <caption>Invocation</caption>
  <tr><th>Name</th><th>Value</th></tr>
  <tr><td>Daemon</td><td>%s</td></tr>
  <tr><td>Duration (sec)</td><td>%d</td></tr>
  <tr><td>Count (procs)</td><td>%d</td></tr>
  <tr><td>Sleep (sec)</td><td>%d</td></tr>
  <tr><td>Log File</td><td>%s</td></tr>
  <tr><td>PID FIle</td><td>%s</td></tr>
</table>
<table class="logs">
  <caption>Event Log</caption>
  <tr>
    <th>PID</th>
    <th>Name</th>
    <th>Log Level</th>
    <th>Date/Time</th>
    <th>Message</th>
  </tr>
""",

    'xml':
       """<invocation daemon="%s" duration="%d" count="%d" sleep="%d" logfile="%s" pidfile="%s">
</invocation>
""",

    'json':
        """
[ "invocation" ]
""" 
    }

#
# A log entry format for each output method
#
logformat = {
    'text': """%(levelname)s:%(name)s:%(process)s: %(message)s""",

    'html': 
"""<tr class="logentry">
  <td class="process">%(process)s</td>
  <td class="logname">%(name)s</td>
  <td class="loglevel">%(levelname)s</td>
  <td class="datetime">%(asctime)s</td>
  <td class="message">%(message)s</td>
</tr>""",

    'xml':  

"""<logentry pid='%(process)s' name='%(name)s' level='%(levelname)s' time='%(asctime)s' >
%(message)s
</logentry>""",

    'json':

"""{
  "pid":     "%(process)s",
  "level":   "%(levelname)s",
  "name":    "%(name)s",
  "time":    "%(asctime)s",
  "message": "%(message)s"
},"""
    }

summaryformat = {
    'text': 
    """--------------------------------------------------------------------------------
summary
""",

    'html':
        """    </table>
<table class="summary">
  <caption>Summary</caption>
  <tr><th>Name</th><th>Value</th></tr>
  <tr><td>Start Time</td><td>-</td></tr>
  <tr><td>End Time</td><td>-</td></tr>
  <tr><td>Duration</td><td>-</td></tr>
</table>

""",
    
    'xml': 
    """<summary>
</summary>
""",

    'json':
"""summary = [ 
],
"""

    }

#
# A footer format for each log output format
#
footerformat = {
    'text': 
    """--------------------------------------------------------------------------------
""",
    
    'html':
        """
  </body>
</html>
""",
    
    'xml':
        """  </logentries>
</runreport>
""",
    
    'json':
        """  ]
}
"""
    
    }




#
# sample take from:
# http://www.noah.org/wiki/Daemonize_Python
#
def daemonize (stdin='/dev/null', stdout='/dev/null', stderr='/dev/null',
               pidfile=None):

    '''This forks the current process into a daemon. The stdin, stdout, and
    stderr arguments are file names that will be opened and be used to replace
    the standard file descriptors in sys.stdin, sys.stdout, and sys.stderr.
    These arguments are optional and default to /dev/null. Note that stderr is
    opened unbuffered, so if it shares a file with stdout then interleaved
    output may not appear in the order that you expect. '''

    # flush any pending output before forking
    sys.stdout.flush()
    sys.stderr.flush()

    # Do first fork.
    try: 
        pid = os.fork() 
        if pid > 0:
            sys.exit(0)   # Exit first parent.
    except OSError, e: 
        sys.stderr.write ("fork #1 failed: (%d) %s\n" % (e.errno, e.strerror) )
        sys.exit(1)

    # Decouple from parent environment.
    os.chdir("/") 
    os.umask(0) 
    os.setsid() 


    # Do second fork.
    try: 
        pid = os.fork() 
        if pid > 0:
            sys.exit(0)   # Exit second parent.
    except OSError, e: 
        sys.stderr.write ("fork #2 failed: (%d) %s\n" % (e.errno, e.strerror) )
        sys.exit(1)

    # Now I am a daemon!
    logger.debug("I am a daemon")
    # if the caller asked for a pidfile, write it
    if pidfile:
        logger.debug("writing PID file %s" % pidfile)
        pf = file(pidfile, "w")
        pf.write("%d\n" % os.getpid())
        pf.close()

    # Redirect standard file descriptors.
    if stdin:
 