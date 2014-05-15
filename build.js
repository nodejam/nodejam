start = Date.now();

argv = require('optimist').argv;
threads = argv.threads ? parseInt(argv.threads) : 8;
build = require('fora-build').create({ threads: threads });

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

if (!argv.client)
    server = build.configure(serverConfig, 'server');
if (!argv.server)
    client = build.configure(clientConfig, 'www-client');
    

if (!argv.client && !argv.server && !argv.norun) {
    build.onBuildComplete(function*() {
        console.log("Restarting the server.....");
        var script = require('child_process').spawn("sh", ["server/run.sh"]);
        script.stdout.on('data', function (data) {
          console.log(data.toString());
        });
    });
}

monitor = !argv.client && !argv.server && !argv.norun;

build.start(monitor, function() {
    var elapsed = Date.now() - start;
    
    if (!argv.client) {
        var serverTime = (server.state.end - server.state.start)/1000;
        console.log("Build(server): " + serverTime + "s");        
    }
    if (!argv.server) {
        var clientTime = (client.state.end - client.state.start)/1000;
        console.log("Build(client): " + clientTime + "s");
    }
    console.log("Build(total): " + (elapsed/1000) + "s");    
});
