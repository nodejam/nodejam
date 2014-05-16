start = Date.now();

optimist = require('optimist')
    .usage('Build the fora project.\nUsage: $0')
    .alias('h', 'help')
    .describe('norun', "Do not start the server after building")
    .describe('client', "Build the client and do not start the server")
    .describe('server', "Build the server and do not start the server")
    .describe('threads', "Number of threads to use for the build")
    .describe('help', 'Print this help screen');

argv = optimist.argv;

threads = argv.threads ? parseInt(argv.threads) : 8;
build = require('fora-build').create({ threads: threads });

serverConfig = require('./server/build-config');
clientConfig = require('./www-client/build-config');

if (argv.help || argv.h) {
    optimist.showHelp();
    process.exit(0);
}

if (argv.client || argv.server) {
    buildClient = argv.client;    
    buildServer = argv.server;
    norun = true;
} else {
    buildClient = true;
    buildServer = true;
    norun = argv.norun;
}    

if (buildServer)
    server = build.configure(serverConfig, 'server');
if (buildClient)
    client = build.configure(clientConfig, 'www-client');
    
build.onBuildComplete(function*() {
    var elapsed = Date.now() - start;
    
    if (buildServer) {
        var serverTime = (server.state.end - server.state.start)/1000;
        console.log("Build(server): " + serverTime + "s");        
    }
    if (buildClient) {
        var clientTime = (client.state.end - client.state.start)/1000;
        console.log("Build(client): " + clientTime + "s");
    }
    console.log("Build(total): " + (elapsed/1000) + "s");    
});


if (!norun) {
    build.onBuildComplete(function*() {
        console.log("Restarting the server.....");
        var script = require('child_process').spawn("sh", ["server/run.sh"]);
        script.stdout.on('data', function (data) {          
            process.stdout.write(data.toString());
        });
    });
}

build.start(!norun, { threads: argv.threads || 8 });
