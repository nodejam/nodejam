start = Date.now();

build = require('fora-build').create({ threads: 6 });
argv = require('optimist').argv

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

build.configure(serverConfig, 'server');
build.configure(clientConfig, 'www-client');
build.run(true, function() {
    elapsed = Date.now() - start;
    console.log("Build took " + (elapsed/1000) + " seconds");    
});


