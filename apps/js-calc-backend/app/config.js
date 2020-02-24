var config = {}

config.instrumentationKey = process.env.INSTRUMENTATIONKEY;
if (config.instrumentationKey && config.instrumentationKey == "dummyValue")
{
    config.instrumentationKey = null;
}
config.port = process.env.PORT || 8080;
config.laggy = process.env.LAGGY;
config.buggy = process.env.BUGGY;

config.version = "default - latest";

const fs = require('fs');
if (fs.existsSync('version/info.txt')) {
   console.log('found version file');
   config.version = fs.readFileSync('version/info.txt', 'utf8');
}


module.exports = config;
