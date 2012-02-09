#!/bin/env node
//  OpenShift sample Node application

var express = require('express');
var fs      = require('fs');

//  Local cache for static content [fixed and loaded at startup].
var zcache = { 'index.html': '' };

//  Add contents of index.html to local cache.
fs.readFile('./index.html', function (err, data) {
    if (err) {
        throw err;
    }
    zcache['index.html'] = data;
});


// Create "express" server.
var app  = express.createServer();


/*  =====================================================================  */
/*  Setup route handlers.  */
/*  =====================================================================  */

// Handler for GET /health
app.get('/health', function(req, res){
    res.send('1');
});

// Handler for GET /asciimo
app.get('/asciimo', function(req, res){
    res.redirect("https://a248.e.akamai.net/assets.github.com/img/d84f00f173afcf3bc81b4fad855e39838b23d8ff/687474703a2f2f696d6775722e636f6d2f6b6d626a422e706e67");
});

// Handler for GET /
app.get('/', function(req, res){
    res.send(zcache['index.html'], {'Content-Type': 'text/html'});
});


//  Get the environment variables we need.
var ipaddr  = process.env.OPENSHIFT_INTERNAL_IP;
var port    = process.env.OPENSHIFT_INTERNAL_PORT || 8080;

if (typeof ipaddr === "undefined") {
   console.warn('No OPENSHIFT_INTERNAL_IP environment variable');
}

//  terminator === the termination handler.
function terminator(sig) {
   if (typeof sig === "undefined") {
      console.log('Node server stopped.');
      return;
   }
   console.log('Received %s - terminating Node server ...', sig);
   process.exit(1);
}

//  Process on exit and certain signals.
process.on('exit',    function() { terminator();          });
process.on('SIGHUP',  function() { terminator('SIGHUP');  });
process.on('SIGINT',  function() { terminator('SIGINT');  });
process.on('SIGQUIT', function() { terminator('SIGQUIT'); });
process.on('SIGTERM', function() { terminator('SIGTERM'); });

//  And start the app on that interface (and port).
app.listen(port, ipaddr, function() {
   console.log('Node server started on %s:%d ...', ipaddr, port);
});

