var config = {}

config.endpoint = "http://" +  process.env.ENDPOINT;
config.instrumentationKey = process.env.INSTRUMENTATIONKEY;
config.port = process.env.PORT || 80;
config.redisHost = process.env.REDIS_HOST;
config.redisAuth = process.env.REDIS_AUTH;

module.exports = config;