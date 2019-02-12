const express = require('express');
const morgan = require('morgan');
const OS = require('os');
const app = express();
app.use(morgan('combined'));


app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html')
});

app.post('/', function(req, res) {
  var endDate = new Date();
  var remoteAddress = req.connection.remoteAddress;
  var serverResult = JSON.stringify({ timestamp: endDate, host: OS.hostname(), remote: remoteAddress } );
  console.log(serverResult);
  res.send(serverResult.toString());
});

app.get('/ping', (req, res) => {
  var endDate = new Date();
  var remoteAddress = req.connection.remoteAddress;
  var serverResult = JSON.stringify({ timestamp: endDate, host: OS.hostname(), remote: remoteAddress } );
  console.log(serverResult);
  res.send(serverResult.toString());
});

var listener = app.listen(process.env.PORT || 80, function() {
 console.log('listening on port ' + listener.address().port);
});

