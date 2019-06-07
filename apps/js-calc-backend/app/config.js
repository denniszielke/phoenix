var config = {}

config.instrumentationKey = process.env.INSTRUMENTATIONKEY;
if (config.instrumentationKey && config.instrumentationKey == "dummyValue")
{
    config.instrumentationKey = null;
}
config.port = process.env.PORT || 8080;
config.laggy = process.env.LAGGY;
config.buggy = process.env.BUGGY;

module.exports = config;
