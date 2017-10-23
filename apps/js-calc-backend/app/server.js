require('dotenv-extended').load();

const express = require('express');
const app = express();
const morgan = require('morgan');

const config = require('./config');

var appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey);
    appInsights.start();
}
var client = appInsights.defaultClient;

// add logging middleware
app.use(morgan('dev'));

// Routes

app.get('/', function(req, res) {
    console.log('received request');
    res.send('Hi!');
});
app.get('/ping', function(req, res) {
    client.trackEvent({ name: 'ping-js-backend-received' });
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
        client.trackEvent( { name: "calculation-jsbackend-call", properties: { number: req.headers.number } });
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
    if (config.instrumentationKey){ 
        var endDate = new Date();
        var duration = endDate - startDate;
        client.trackEvent({ name: "calculation-jsbackend-result", properties: { result: resultValue } });
        client.trackMetric({ name:"calculation-jsbackend-duration", value: duration });
    }
    var serverResult = JSON.stringify({ timestamp: endDate, value: resultValue } );
    console.log(serverResult);
    res.send(serverResult.toString());
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers)
    if (config.instrumentationKey){ 
        client.trackEvent({ name: "dummy-jsbackend-call"});
    }
    res.send('42');
});

// Listen
if (config.instrumentationKey){ 
    client.trackEvent({ name: "jsbackend-initializing"});
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);