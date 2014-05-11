build = require('fora-build');
argv = require('optimist').argv

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

build.configure(serverConfig, 'server');
build.configure(clientConfig, 'www-client');

if argv.debug
    build.watch()
else
    build.run()

