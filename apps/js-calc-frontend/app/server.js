require('dotenv-extended').load();
const config = require('./config');
var appInsights = require("applicationinsights");
if (config.instrumentationKey){ 
    appInsights.setup(config.instrumentationKey)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectPerformance(true);
    appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "calc-frontend";
    appInsights.start();
}
var client = appInsights.defaultClient;
client.commonProperties = {
	slot: config.version
};

const express = require('express');
const app = express();
const morgan = require('morgan');
const request = require('request');
const OS = require('os');
const redis = require("redis");

var redisClient = null;

var publicDir = require('path').join(__dirname, '/public');

// add logging middleware
app.use(morgan('dev'));
app.use(express.static(publicDir));

// Routes
app.get('/ping', function(req, res) {
    console.log('received ping');
    var pong = { response: "pong!", host: OS.hostname(), version: config.version };
    console.log(pong);
    res.send(pong);
});

app.get('/healthz', function(req, res) {
    res.send('OK');
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
        client.trackEvent( { name: "calculation-js-frontend-call-start"});
    }
    var victim = false;

    var randomvictim = Math.floor((Math.random() * 20) + 1);
    if (config.buggy && randomvictim){
        victim = true;
    }

    if (config.redisHost && config.redisAuth && redisClient == null) {
        try{
            redisClient = redis.createClient(6379, config.redisHost, {auth_pass: config.redisAuth, password: config.redisAuth});
        }
        catch(e){
            console.log(e);
            redisClient=null;
        }
    }

    if (redisClient){
        console.log("calling redis:" + config.redisHost + " with " + config.redisAuth);
        var cachedResult = redisClient.get(req.headers.number, function(err, reply) {
            if (reply && !err){
                if (config.instrumentationKey){ 
                    var endDate = new Date();
                    var duration = endDate - startDate;
                    client.trackDependency(
                        { target: config.redisHost, dependencyTypeName: "REDIS", name: "calculation-cache", 
                        data:"calculate number " + req.headers.number, 
                        duration: duration, resultCode:0, success: true});
                    client.trackEvent({ name: "calculation-js-frontend-cache", properties: {randomVictim: victim, cached: true} });
                    client.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
                }
                console.log("cache hit");

                var calcResult = JSON.parse(reply); 

                var response = { host: OS.hostname(), version: config.version, 
                    backend: { host: calcResult.host, version: calcResult.version, value: calcResult.value, remote: calcResult.remote, timestamp: calcResult.timestamp } };
    
                console.log(response);
                res.send(response);              
            }else{
                console.log(err);
                console.log("cache miss");
                var formData = {
                    received: new Date().toLocaleString(), 
                    number: req.headers.number
                };
                var options = { 
                    'url': config.endpoint + '/api/calculation',
                    'form': formData,
                    'headers': {
                        'number': req.headers.number,
                        'randomvictim': victim
                    }
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
                        client.trackRequest({name:"POST /api/calculation", url: options.url, duration:duration, resultCode:200, success:true});
                        client.trackEvent({ name: "calculation-js-frontend-call-complete", properties: {randomVictim: victim, cached: false} });
                        client.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
                    }
                                       
                    var cachedResult = redisClient.set(req.headers.number.toString(), body.toString(), function(err, reply) {
                        console.log("cache save");
                        console.log(reply);
                    });

                    var calcResult = JSON.parse(body); 

                    var response = { host: OS.hostname(), version: config.version, 
                        backend: { host: calcResult.host, version: calcResult.version, value: calcResult.value, remote: calcResult.remote, timestamp: calcResult.timestamp } };
        
                    console.log(response);
                    res.send(response);
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
            'headers': {
                'number': req.headers.number,
                'randomvictim': victim
            }
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
                console.log("sending telemetry");
                client.trackEvent({ name: "calculation-js-frontend-call-complete", properties: {randomVictim: victim, cached: false} });
                client.trackRequest({name:"POST /api/calculation", url: options.url, duration:duration, resultCode:200, success:true});
                client.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
            }
            
            if (redisClient){
                var cachedResult = redisClient.set(req.headers.number, body, function(err, reply) {
                    console.log(reply);
                });
            }
            
            var calcResult = JSON.parse(body); 

            var response = { host: OS.hostname(), version: config.version, 
                backend: { host: calcResult.host, version: calcResult.version, value: calcResult.value, remote: calcResult.remote, timestamp: calcResult.timestamp } };

            console.log(response);
            res.send(response);
        });
    }
    
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    if (config.instrumentationKey){ 
        client.trackEvent({ name: "dummy-js-frontend-call"});
    }
    res.send('42');
});

console.log(config);
console.log(OS.hostname());
// Listen
if (config.instrumentationKey){ 
    client.trackEvent({ name: "js-frontend-initializing"});
}
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);