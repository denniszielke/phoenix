const request = require('request');

function intervalFunc() {
  var randomNumber = Math.floor((Math.random() * 10000000) + 1);
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;',
    'number': randomNumber
  }; 
  var options = { 
    'url': endpoint,
    'headers': headers
  }; 

  request.post(options, function(err, res, body) {
    var endDate = new Date();
    console.log(endDate.getTime() + " " + body);
  });
}

function noop() {
  var endDate = new Date();
  console.log(endDate.getTime() + " doing nothing");
}

if ( process.env.ENDPOINT ) {
  var endpoint = "http://" +  process.env.ENDPOINT;
  setInterval(intervalFunc, 10);
} else {
  setInterval(noop, 10000);
}