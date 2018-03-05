var config = {}

config.instrumentationKey = process.env.INSTRUMENTATIONKEY;
config.port = process.env.PORT || 80;

module.exports = config;
