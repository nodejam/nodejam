start = Date.now();

build = require('../fora-build').create({ threads: 8 });

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

server = build.configure(serverConfig, 'server');
client = build.configure(clientConfig, 'www-client');

build.start(true, function() {
    var elapsed = Date.now() - start;
    var serverTime = (server.state.end - server.state.start)/1000;
    var clientTime = (client.state.end - client.state.start)/1000;
    console.log("Build took " + (elapsed/1000) + " seconds (server: " + serverTime + "s, client: " + clientTime + "s)");    
});
