require('dotenv-extended').load();
const config = require('./config');
const appInsights = require("applicationinsights");

if (config.aicstring){ 
    appInsights.setup(config.aicstring)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .setSendLiveMetrics(true)
    .setDistributedTracingMode(appInsights.DistributedTracingModes.AI_AND_W3C);
    appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "http-frontend";
    appInsights.start();
    appInsights.defaultClient.commonProperties = {
        slot: config.version
    };
}

const swaggerUi = require('swagger-ui-express'), swaggerDocument = require('./swagger.json');

const express = require('express');
const app = express();
app.use(express.json())
const morgan = require('morgan');
const OS = require('os');
const axios = require('axios');
const redis = require("redis");

var redisClient = null;

var publicDir = require('path').join(__dirname, '/public');

app.use(morgan('dev'));
app.use(express.static(publicDir));
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Routes
app.get('/ping', function(req, res) {
    console.log('received ping');
    const sourceIp = req.connection.remoteAddress;
    const forwardedFrom = (req.headers['x-forwarded-for'] || '').split(',').pop();
    const pong = { response: "pong!", correlation: "", host: OS.hostname(), source: sourceIp, forwarded: forwardedFrom, version: config.version };
    console.log(pong);
    res.status(200).send(pong);
});
app.get('/healthz', function(req, res) {
    const data = {
        uptime: process.uptime(),
        message: 'Ok',
        date: new Date()
      }
    res.status(200).send(data);
});

app.get('/appInsightsConnectionString', function(req, res) {
    console.log('returned app insights connection string');
    if (config.aicstring){ 
        res.send(config.aicstring);
    }
    else{
        res.send('');
    }
});

app.post('/api/calculate/:number?', async function(req, res) {
    console.log("received frontend request:");
    console.log("headers:");
    console.log(req.headers);
    console.log("body:");
    console.log(req.body);
    if (req.body.number)
    console.log("body number: " + req.body.number.toString());
    if (req.params.number)
    console.log("path number: " + req.params.number.toString());
    const requestId = req.headers['traceparent'] || '';
    let victim = false;
    var targetNumber = 0;
    var endDate = null;
    const remoteAddress = req.connection.remoteAddress;
    const forwardedFrom = (req.headers['x-forwarded-for'] || '').split(',').pop();

    if (config.aicstring){ 
        var startDate = new Date();
    }

    try{
        if ( req.params.number && req.params.number.toString().length > 0 )
        {
            targetNumber = req.params.toString();            
        }else if (req.body.number && req.body.number.toString().length > 0 ){
            targetNumber = req.body.number.toString();
        }
        else
        {
            targetNumber = 42;
        }
    }catch(e){
        console.log("correlation: " + requestId);
        console.log(e);
        res.status(500).send({ timestamp: endDate, values: [ 'e', 'r', 'r'], host: OS.hostname(), remote: remoteAddress, forwarded: forwardedFrom, version: config.version });
    }

    var randomvictim = Math.floor((Math.random() * 20) + 1);
    if (config.buggy && randomvictim > 19){
        victim = true;
        if (config.aicstring){ 
            appInsights.defaultClient.trackEvent( { name: "calculation-js-frontend-victim"});
        }

        axios({
            method: 'get',
            url: 'https://catfact.ninja/fact',
            headers: {    
                'Content-Type': 'application/json'
            }}).then(function (response) { 
                console.log("cat facts received");
            }).catch(function (error) {
                console.log("no cat fact");
             });
        console.log("request is randomly selected as victim");
    }

    if (config.redisHost && config.redisAuth && redisClient == null) {
        console.log("calling redis:" + config.redisHost + " with " + config.redisAuth);
        try{
            redisClient = redis.createClient({
                // rediss for TLS
                url: `rediss://${config.redisHost}:6380`,
                password: config.redisAuth
            });

            await redisClient.connect();
        }
        catch(e){
            console.log(e);
            redisClient=null;
        }
    }

    if (redisClient){
        
        var cachedResult = await redisClient.get(targetNumber);
        console.log(cachedResult);

        if (config.aicstring){ 
            endDate = new Date();
            var duration = endDate - startDate;
            appInsights.defaultClient.trackDependency(
                { target: config.redisHost, dependencyTypeName: "REDIS", name: config.redisHost, 
                data:"calculate number " + req.headers.number, 
                duration: duration, resultCode:0, success: true});
                appInsights.defaultClient.trackEvent({ name: "calculation-js-frontend-cache", properties: {randomVictim: victim, cached: true} });
                appInsights.defaultClient.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
        }

        if (cachedResult){
            console.log("cache hit");

            appResponse = {
                timestamp: endDate, correlation: requestId,
                host: OS.hostname(), 
                version: config.version, 
                backend: { 
                    host: "cache", 
                    version: config.version, 
                    values: cachedResult, 
                    remote: "cache", 
                    timestamp: endDate } 
            };
            console.log(appResponse);
            res.status(200).send(appResponse);
        }else {
            console.log("cache miss");

            axios({
                method: 'post',
                url: config.endpoint + '/api/calculate',
                headers: {    
                    'Content-Type': 'application/json'
                },
                data: {
                    number: targetNumber,
                    randomvictim: victim,
                }})
                .then(function (response) {
                    console.log("received backend response:");
                    console.log(response.data);
                    const appResponse = {
                        timestamp: endDate, correlation: requestId,
                        host: OS.hostname(), version: config.version, 
                        backend: { 
                            host: response.data.host, 
                            version: response.data.version, 
                            values: response.data.values, 
                            remote: response.data.remote, 
                            timestamp: response.data.timestamp } 
                    };
                    
                    if (config.aicstring){ 
                        appInsights.defaultClient.trackEvent({ name: "calculation-js-frontend-call-complete", properties: {randomVictim: victim, cached: false} });
                        appInsights.defaultClient.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
                    }
                    
                    var cachedResult = redisClient.set(targetNumber, appResponse.backend.values.toString());
                    res.status(200).send(appResponse);

                }).catch(function (error) {
                    console.log("error:");
                    console.log(error);
                    const backend = { 
                        host: error.response.data.host || "frontend", 
                        version: error.response.data.version || "red", 
                        values: error.response.data.values || [ 'b', 'u', 'g'], 
                        timestamp: error.response.data.timestamp || ""
                    };
                    res.send({ backend: backend, correlation: requestId, host: OS.hostname(), version: config.version });
                });
        }

    }else{
        axios({
            method: 'post',
            url: config.endpoint + '/api/calculate',
            headers: {    
                'Content-Type': 'application/json'
            },
            data: {
                number: targetNumber,
                randomvictim: victim,
            }})
            .then(function (response) {
                console.log("received backend response:");
                console.log(response.data);
                const appResponse = {
                    timestamp: endDate, correlation: requestId,
                    host: OS.hostname(), version: config.version, 
                    backend: { 
                        host: response.data.host, 
                        version: response.data.version, 
                        values: response.data.values, 
                        remote: response.data.remote, 
                        timestamp: response.data.timestamp } 
                };
                
                if (config.aicstring){ 
                    appInsights.defaultClient.trackEvent({ name: "calculation-js-frontend-call-complete", properties: {randomVictim: victim, cached: false} });
                    appInsights.defaultClient.trackMetric({ name:"calculation-js-frontend-duration", value: duration });
                }
                
                res.status(200).send(appResponse);

            }).catch(function (error) {
                console.log("error:");
                console.log(error);
                const backend = { 
                    host: error.response.data.host || "frontend", 
                    version: error.response.data.version || "red", 
                    values: error.response.data.values || [ 'b', 'u', 'g'], 
                    timestamp: error.response.data.timestamp || ""
                };
                res.send({ backend: backend, correlation: requestId, host: OS.hostname(), version: config.version });
            });
    }
    
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    if (config.aicstring){ 
        client.trackEvent({ name: "dummy-js-frontend-call"});
    }
    res.send({ values: "[ 42 ]", host: OS.hostname(), version: config.version });
});

process.on("exit", function(){
    if (redisClient != null)
    {
        console.log("discconnecting redis");
        redisClient.disconnect();
    }
});

console.log(config);
console.log(OS.hostname());
app.listen(config.port);
console.log('Listening on localhost:'+ config.port);