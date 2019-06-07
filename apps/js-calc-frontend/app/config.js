var config = {}

config.endpoint = "http://" +  process.env.ENDPOINT;
config.instrumentationKey = process.env.INSTRUMENTATIONKEY;
if (config.instrumentationKey && config.instrumentationKey == "dummyValue")
{
    config.instrumentationKey = null;
}
config.port = process.env.PORT || 8080;
config.redisHost = process.env.REDIS_HOST;
config.redisAuth = process.env.REDIS_AUTH;

module.exports = config;