require('dotenv-extended').load();

const express = require('express');
const app = express();
const morgan = require('morgan');
const request = require('request');
const OS = require('os');
const redis = require("redis");
const config = require('./config');

var appInsights = require("applicationinsights");

if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectDependencies(true)
    .start();
    appInsights.defaultClient.context.keys.cloudRole = "frontend";
}
var client = appInsights.defaultClient;

var redisClient = null;
if (config.redisHost && config.redisAuth) {
    redisClient = redis.createClient(6380, config.redisHost, {auth_pass: config.redisAuth, tls: {servername: config.redisHost}});
}

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

    if (redisClient){
        var cachedResult = redisClient.get(req.headers.number, function(err, reply) {
            if (reply && !err){
                if (config.instrumentationKey){ 
                    var endDate = new Date();
                    var duration = endDate - startDate;
                    client.trackDependency(
                        { target: config.redisHost, dependencyTypeName: "HTTP", name: "calculation-cache", 
                        data:"calculate number " + req.headers.number, 
                        duration: duration, resultCode:0, success: true});
                    client.trackEvent({ name: "calculation-jsfrontend-cache" });
                    client.trackMetric({ name:"calculation-jsfrontend-duration", value: duration });
                }
                console.log("cache hit");
                res.send(reply);            
                console.log(reply);                
            }else{
                // if (err){
                //     console.log("cache error:");
                //     console.log(err);
                //     if (config.instrumentationKey){ 
                //         client.trackException(err);
                //     }
                // }
                console.log("cache miss");
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
                            { target: options.url, dependencyTypeName: "HTTP", name: "calculation-backend", 
                            data:"calculate number " + req.headers.number, 
                            duration: duration, resultCode:0, success: true});
                        client.trackEvent({ name: "calculation-jsfrontend-result" });
                        client.trackMetric({ name:"calculation-jsfrontend-duration", value: duration });
                    }
                                       
                    var cachedResult = redisClient.set(req.headers.number, body, function(err, reply) {
                        console.log("cache save");
                        console.log(reply);
                    });
                            
                    console.log(body);
                    res.send(body);
                });    
            }
        });
    }else{
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
            
            if (redisClient){
                var cachedResult = redisClient.set(req.headers.number, body, function(err, reply) {
                    console.log(reply);
                });
            }

            console.log(body);
            res.send(body);
        });
    }
    
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        client.trackEvent({ name: "dummy-jsfrontend-call"});
    }
    res.send('42');
});

console.log(config);
console.log(OS.hostname());
// Listen
if (config.instrumentationKey){ 
    client.trackEvent({ name: "jsfrontend-initializing"});
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);