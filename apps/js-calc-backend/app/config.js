var config = {}
const fs = require('fs');
const OS = require('os');

config.aicstring = process.env.AIC_STRING;
if (config.aicstring && config.aicstring == "dummyValue")
{
    config.aicstring = null;
}

config.port = process.env.PORT || 8080;
config.laggy = process.env.LAGGY || true;
config.buggy = process.env.BUGGY || true;
config.writepath = process.env.WRITEPATH;
config.version = "default - latest";

if (process.env.VERSION && process.env.VERSION.length > 0)
{
    console.log('found version environment variable');
    config.version = process.env.VERSION;
}
else {
    const fs = require('fs');
    if (fs.existsSync('version/info.txt')) {
    console.log('found version file');
    config.version = fs.readFileSync('version/info.txt', 'utf8');
    }
}

if (config.writepath && fs.existsSync(config.writepath)){
    var startDate = new Date();
    const content = startDate.toLocaleDateString() + "-" + startDate.toLocaleTimeString() + '-' + OS.hostname() + "-starting-" + process.pid + "\r\n";
    fs.writeFile(config.writepath + 'lifecycle.txt', content, { flag: 'a+' }, err => { console.log(err); })
    process.on('SIGTERM', function () {
        var endDate = new Date();
        const content = endDate.toLocaleDateString() + "-" + endDate.toLocaleTimeString() + '-' + OS.hostname() + "-stopping-" + process.pid + "\r\n";
        fs.writeFile(config.writepath + 'lifecycle.txt', content, { flag: 'a+' }, err => { console.log(err); })
    });      
}

module.exports = config;
