const request = require('request');

function intervalFuncPost() {
  var randomNumber = Math.floor((Math.random() * 10000000) + 1);
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;',
    'number': randomNumber
  }; 
  var options = { 
    'url': process.env.POST_ENDPOINT,
    'headers': headers
  }; 

  request.post(options, function(err, res, body) {
    var endDate = new Date();
    console.log(endDate.getTime() + " " + body);
  });
}

function intervalFuncGet() {
  request.get(process.env.GET_ENDPOINT, function(err, res, body) {
    var endDate = new Date();
    console.log(endDate.getTime() + " " + body);
  });
}

function noop() {
  var endDate = new Date();
  console.log(endDate.getTime() + " doing nothing");
}

if ( process.env.GET_ENDPOINT ) {
  setInterval(intervalFuncGet, 10);
} else if (process.env.GET_ENDPOINT)
{
  setInterval(intervalFuncPost, 10);
}
else {
  setInterval(noop, 10000);
}