require('dotenv-extended').load();

const express = require('express');
const app = express();
const morgan = require('morgan');

const config = require('./config');
const appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey).setAutoCollectRequests(true).start();
}

// add logging middleware
app.use(morgan('dev'));

// Routes

app.get('/', function(req, res) {
    console.log('received request');
    res.send('Hi');
});
app.get('/ping', function(req, res) {
    appInsights.defaultClient.trackEvent('ping-backend-received');
    console.log('received ping');
    res.send('Pong');
});

// curl -X POST --header "number: 3" http://localhost:3001/api/calculation
app.post('/api/calculation', function(req, res) {
    console.log("received client request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        var startDate = new Date();
        appInsights.defaultClient.trackEvent("calculation-backend-call-start", { value: req.headers.number });
    }
    var resultValue = 0;
    try{
        var randomWait = Math.random() * 20;
        var number = parseInt(req.headers.number);
        resultValue = number * number * randomWait;
    }catch(e){
        console.log(e);
        if (config.instrumentationKey){ 
            appInsights.defaultClient.trackException(e);
        }
        resultValue = 0;
    }
    if (config.instrumentationKey){ 
        var endDate = new Date();
        var duration = endDate - startDate;
        appInsights.defaultClient.trackEvent("calculation-backend-call-end", { value: resultValue });
        appInsights.defaultClient.trackMetric("calculation-backend-duration", duration);
    }
    console.log(resultValue);
    res.send(resultValue.toString());
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers)
    if (config.instrumentationKey){ 
        appInsights.defaultClient.trackEvent("dummy-data-call");
    }
    res.send('42');
});

// Listen
if (config.instrumentationKey){ 
    appInsights.defaultClient.trackEvent('backend-initializing');
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);