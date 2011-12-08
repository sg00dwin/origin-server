"""
(C) Copyright 2011, 10gen

This is a label on a mattress. Do not modify this file!
"""

import threading, time, pymongo, traceback

nonBlockingStatsAgentVersion = "1.3.7"

class NonBlockingMongoStatsThread( threading.Thread ):
    """ Pull the non-blocking data from the various hosts. """

    def __init__( self, hostDef, mmsAgent ):
        """ Initialize the object """
        self.hostDef = hostDef
        self.mmsAgent = mmsAgent
        self.logger = mmsAgent.logger
        self.monitorConn = None
        self.passes = 0
        self.mongoVersion = None
        threading.Thread.__init__( self )

    def run( self ):
        """ The thread to collect stats """

        hostKey = self.hostDef['hostKey']

        self.logger.info( 'starting non-blocking stats monitoring: ' + hostKey )

        sleepTime = ( self.mmsAgent.collectionInterval / 2 ) - 1

        if ( sleepTime < 1 ):
            sleepTime = 1

        while not self.mmsAgent.done and self.hostDef['threadRunning']:
            try:
                if self.passes > 0:
                    time.sleep( sleepTime )

                self.passes = self.passes + 1

                if not self.mmsAgent.haveHostDef( hostKey ):
                    continue

                # Close the connection periodically
                if self.passes % 60 == 0:
                    if self.monitorConn is not None:
                        self.monitorConn.disconnect()
                        self.monitorConn = None

                if not self.monitorConn:
                    self.monitorConn = pymongo.Connection( self.hostDef['mongoUri'], slave_okay=True )

                # Verify the connection.
                if not self.mmsAgent.isValidMonitorConn( self.hostDef, self.monitorConn ):
                    self.monitorConn = None
                    continue

                stats = self._collectStats()

                stats['host'] = self.hostDef['hostname']
                stats['port'] = self.hostDef['port']

                # Make sure we ended up with the same connection.
                if not self.mmsAgent.isValidMonitorConn( self.hostDef, self.monitorConn ):
                    self.monitorConn = None
                    continue

                self.mmsAgent.setHostState( hostKey, 'mongoNonBlocking', stats )

            except Exception, e:
                if self.monitorConn is not None:
                    try:
                        self.monitorConn.disconnect()
                        self.monitorConn = None
                    except:
                        pass
                self.logger.warning( 'Problem collecting non-blocking data from (check if it is up and DNS): ' + hostKey + ' - ' +  traceback.format_exc( e ) )

        self.logger.info( 'stopping non-blocking stats monitoring: ' + hostKey )

        if self.monitorConn is not None:
            self.monitorConn.disconnect()
            self.monitorConn = None

    def _collectStats( self ):
        """ Make the call to mongo host and collect the data """
        root = {}

        # Set the agent version and hostname.
        root['agentVersion'] = self.mmsAgent.agentVersion
        root['agentHostname'] = self.mmsAgent.agentHostname
        root['agentSessionKey'] = self.mmsAgent.sessionKey

        root['serverStatus'] = self.monitorConn.admin.command( 'serverStatus' )

        # The server build info
        root['buildInfo'] = self.monitorConn.admin.command( 'buildinfo' )

        # Try and get the version elements.

        if 'buildInfo' in root and 'version' in root['buildInfo']:
            version = root['buildInfo']['version']

            # If this is an rc/pre release, remove the dash.
            try:
                version = version[0:version.index( '-' )]
            except:
                pass

            if version:
                self.mongoVersion = [int(part) for part in version.split( '.' )]

        # Try and get the command line operations
        try:
            root['cmdLineOpts'] = self.monitorConn.admin.command( 'getCmdLineOpts' )
        except:
            pass

        # Get the connection pool stats.
        try:
            root['connPoolStats'] = self.monitorConn.admin.command( 'connPoolStats' )
        except:
            pass

        if self.mongoVersion and self.mongoVersion[0] >= 2:
            try:
                root['startupWarnings'] = self.monitorConn.admin.command( { 'getLog' :"startupWarnings" } )
            except:
                pass

        # Try and get the isSelf data
        try:
            root['isSelf'] = self.monitorConn.admin.command( '_isSelf' )
        except:
            pass

        # Get the params.
        try:
            root['getParameterAll'] = self.monitorConn.admin.command( { 'getParameter' : '*' } )
        except:
            pass

        # Check occasionally to see if we can discover nodes
        isMaster = self.monitorConn.admin.command( 'ismaster' )
        root['isMaster'] = isMaster

        # Try and get the shard version
        if isMaster['ismaster'] and 'msg' in isMaster:
            if isMaster['msg'] != 'isdbgrid':
                try:
                    root['shardVersion'] = self.monitorConn.admin.command( { 'getShardVersion' : 'mdbfoo.foo' } )
                except:
                    pass
        elif isMaster['ismaster']:
            try:
                root['shardVersion'] = self.monitorConn.admin.command( { 'getShardVersion' : 'mdbfoo.foo' } )
            except:
                pass

        # Run the writeBacksQueued command
        if 'msg' not in isMaster:
            try:
                root['writeBacksQueued'] = self.monitorConn.admin.command( 'writeBacksQueued' )
            except:
                pass

        # Check to see if this is a mongod host
        try:
            if isMaster['ismaster'] and isMaster.get('msg', '') == 'isdbgrid':
                root['netstat'] = self.monitorConn.admin.command( 'netstat' )
        except pymongo.errors.OperationFailure:
            pass

        if 'repl' in root['serverStatus']:
            try:
                root['replStatus'] = self.monitorConn.admin.command( 'replSetGetStatus' )
            except pymongo.errors.OperationFailure:
                pass

        return root

