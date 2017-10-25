require('dotenv-extended').load();

const express = require('express');
const app = express();
const morgan = require('morgan');
const request = require('request');

const config = require('./config');

var appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey);
    appInsights.start();
}
var client = appInsights.defaultClient;

var publicDir = require('path').join(__dirname, '/public');

// add logging middleware
app.use(morgan('dev'));
app.use(express.static(publicDir));

// Routes
app.get('/ping', function(req, res) {
    client.trackEvent({ name: 'ping-js-frontend-received' });
    console.log('received ping');
    res.send('Pong');
});

app.get('/api/getappinsightskey', function(req, res) {
    console.log('returned app insights key');
    if (config.instrumentationKey){ 
        res.send(config.instrumentationKey);
    }
    else{
        res.send('');
    }
});

app.post('/api/calculation', function(req, res) {
    console.log("received frontend request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        var startDate = new Date();
        client.trackEvent( { name: "calculation-jsfrontend-call"});
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
                client.trackException(innererr);
            }
        }
        if (config.instrumentationKey){ 
            client.trackDependency(
                { target: options.url, name:"calculation-backend", 
                data:"calculate number " + req.headers.number, 
                duration: duration, resultCode:0, success: true});
            client.trackEvent({ name: "calculation-jsfrontend-result" });
            client.trackMetric({ name:"calculation-jsfrontend-duration", value: duration });
        }
        
        console.log(body);
        res.send(body);
    });
    
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        client.trackEvent({ name: "dummy-jsfrontend-call"});
    }
    res.send('42');
});

// Listen
if (config.instrumentationKey){ 
    client.trackEvent({ name: "jsfrontend-initializing"});
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);