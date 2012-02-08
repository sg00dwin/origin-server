//  Pull in our requirements.
var express = require('express');
var fs      = require('fs');

//  Cache for index.html
var zcache = { 'index.html': '' };

// Cache contents of index.html
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
var port    = process.env.OPENSHIFT_INTERNAL_PORT;

//  And start the app on that interface+port.
app.listen(port, ipaddr);

