require('dotenv-extended').load();

const express = require('express');
const app = express();
const morgan = require('morgan');
const request = require('request');

const config = require('./config');

const appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey).setAutoCollectRequests(true).start();
}

var publicDir = require('path').join(__dirname, '/public');

// add logging middleware
app.use(morgan('dev'));
app.use(express.static(publicDir));

// Routes
app.get('/ping', function(req, res) {
    appInsights.defaultClient.trackEvent('ping-frontend-received');
    console.log('received ping');
    res.send('Pong');
});

app.post('/api/calculation', function(req, res) {
    console.log("received frontend request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        var startDate = new Date();
        appInsights.defaultClient.trackEvent("calculation-frontend-call", { value: req.headers.number });
    }
    var formData = {
        received: new Date().toLocaleString(), 
        number: req.headers.number
    };
    var options = { 
        'url': config.endpoint + '/api/calculation',
        'form': formData,
        'headers': req.headers
    };    
    request.post(options, function(innererr, innerres, body) {
        var endDate = new Date();
        var duration = endDate - startDate;
        if (innererr){
            console.log("error:");
            console.log(innererr);
            if (config.instrumentationKey){ 
                appInsights.defaultClient.trackException(innererr);
            }
        }
        if (config.instrumentationKey){ 
            appInsights.defaultClient.trackEvent("calculation-frontend-call-received", { value: body });
            appInsights.defaultClient.trackMetric("calculation-frontend-call-duration", duration);
        }
        console.log(body);
        res.send(body);
    });
    
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        appInsights.defaultClient.trackEvent("dummy-data-call");
    }
    res.send('42');
});

// Listen
if (config.instrumentationKey){ 
    appInsights.defaultClient.trackEvent('frontend-initializing');
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);