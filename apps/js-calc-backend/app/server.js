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
    appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "http-backend";
    appInsights.start();
    appInsights.defaultClient.commonProperties = {
        slot: config.version
    };
}
const swaggerUi = require('swagger-ui-express'), swaggerDocument = require('./swagger.json');
const OS = require('os');

const express = require('express');
const app = express();
app.use(express.json())
const morgan = require('morgan');
app.use(morgan('dev'));

// Routes
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get('/', function(req, res) {
    console.log('received request');
    res.send('Hi!');
});
app.get('/ping', function(req, res) {
    console.log('received ping');
    const sourceIp = req.connection.remoteAddress;
    const forwardedFrom = (req.headers['x-forwarded-for'] || '').split(',').pop();
    const pong = { response: "pong!", correlation: "", timestamp: new Date(), host: OS.hostname(), source: sourceIp, forwarded: forwardedFrom, version: config.version };
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

var primeFactors = function getAllFactorsFor(remainder) {
    var factors = [], i;
    
    for (i = 2; i <= remainder; i++) {
        try{
            while ((remainder % i) === 0) {
                if (config.laggy && i == 19){
                    console.log("blocking for " + config.laggy +" seconds");
                    var waitTill = new Date(new Date().getTime() +config.laggy * 1000);
                    while(waitTill > new Date()){}
                }
                factors.push(i);
                remainder /= i;
            }
        }catch(e){
            console.log(e);
        }
    }
    
    return factors;
}

// curl -X POST --header "number: 3" --header "randomvictim: true" http://localhost:8082/api/calculate
// curl -X POST --url http://calculator-multicalculator-frontend-svc/api/calculate --header 'content-type: application/json' --data '{"number": "42", "randomvictim": "true", "laggy": "true"}'
app.post('/api/calculate', function(req, res) {
    console.log("received client request:");
    console.log(req.headers);
    console.log(req.body);
    console.log(req.body.number);
    const requestId = req.headers['traceparent'] || '';
    var resultValue = [0];
    try{
        resultValue = primeFactors(req.body.number);
        console.log("calculated:"); 
        console.log(resultValue);
    }catch(e){
        console.log("correlation: " + requestId);
        console.log(e);
        resultValue = [0];
    }
    const endDate = new Date();

    const randomNumber = Math.floor((Math.random() * 20) + 1);
    const remoteAddress = req.connection.remoteAddress;
    const forwardedFrom = (req.headers['x-forwarded-for'] || '').split(',').pop();

    if ((req.body.randomvictim && req.body.randomvictim ===true ) || (config.buggy && randomNumber > 19)){
        console.log("looks like a 19 bug");
        res.status(500).send({ timestamp: endDate, correlation: requestId, values: [ 'b', 'u', 'g'], host: OS.hostname(), remote: remoteAddress, forwarded: forwardedFrom, version: config.version });
    }
    else{
        const serverResult = { timestamp: endDate, correlation: requestId, values: resultValue, host: OS.hostname(), remote: remoteAddress, forwarded: forwardedFrom, version: config.version };
        console.log(serverResult);
        res.status(200).send(serverResult);
    }
});

app.post('/api/dummy', function(req, res) {
    console.log("received dummy request:");
    console.log(req.headers);
    console.log(req.body);
    res.send('42');
});

console.log(config);
console.log(OS.hostname());

app.listen(config.port);
console.log('Listening on localhost:'+ config.port);