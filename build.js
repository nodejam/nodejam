build = require('../fora-build').create({ parallel: 8 });
argv = require('optimist').argv

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

build.configure(serverConfig, 'server');
build.configure(clientConfig, 'www-client');
build.run();

