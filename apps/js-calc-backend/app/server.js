require('dotenv-extended').load();
const config = require('./config');
var appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectPerformance(true);
    appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "calc-backend-svc";
    appInsights.start();
}
var client = appInsights.defaultClient;

const express = require('express');
const app = express();
const morgan = require('morgan');

const OS = require('os');

// add logging middleware
app.use(morgan('dev'));

// Routes

app.get('/', function(req, res) {
    console.log('received request');
    res.send('Hi!');
});
app.get('/ping', function(req, res) {
    console.log('received ping');
    res.send('Pong');
});

var primeFactors = function getAllFactorsFor(remainder) {
    var factors = [], i;
    
    for (i = 2; i <= remainder; i++) {
        while ((remainder % i) === 0) {
            factors.push(i);
            remainder /= i;
        }
    }
    
    return factors;
}

// curl -X POST --header "number: 3" http://localhost:3001/api/calculation
app.post('/api/calculation', function(req, res) {
    console.log("received client request:");
    console.log(req.headers.number);
    if (config.instrumentationKey){ 
        var startDate = new Date();
        client.trackEvent( { name: "calculation-js-backend-call"});
    }
    var resultValue = [0];
    try{
        resultValue = primeFactors(req.headers.number);
        console.log("calculated:"); 
        console.log(resultValue);
    }catch(e){
        console.log(e);
        if (config.instrumentationKey){ 
            client.trackException(e);
        }
        resultValue = [0];
    }
    var endDate = new Date();
    if (config.instrumentationKey){ 
        var duration = endDate - startDate;
        client.trackEvent({ name: "calculation-js-backend-result"});
        client.trackMetric({ name:"calculation-js-backend-duration", value: duration });
    }
    if (req.headers.joker){
        resultValue = "42";
    }
    var remoteAddress = req.connection.remoteAddress;
    var serverResult = JSON.stringify({ timestamp: endDate, value: resultValue, host: OS.hostname(), remote: remoteAddress } );
    console.log(serverResult);
    res.send(serverResult.toString());
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers)
    if (config.instrumentationKey){ 
        client.trackEvent({ name: "dummy-js-backend-call"});
    }
    res.send('42');
});

console.log(config);
console.log(OS.hostname());
// Listen
if (config.instrumentationKey){ 
    client.trackEvent({ name: "js-backend-initializing"});
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);