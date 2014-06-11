(function() {
    "use strict";
    
    var start = Date.now();

    var foraBuild = require('fora-build');
    var spawn = foraBuild.tools.process.spawn({ log: function(data) { process.stdout.write(data); } });

    var optimist = require('optimist')
        .usage('Build the fora project.\nUsage: $0')
        .alias('h', 'help')
        .describe('debug', 'Compile in debug mode')
        .describe('debugweb', 'Start debugger for web')
        .describe('debugapi', 'Start debugger for api')
        .describe('debugclient', 'Enable client-side debugging')
        .describe('client', "Build the client")
        .describe('server', "Build the server")
        .describe('norun', "Do not start the server after building")
        .describe('threads', "Number of threads to use for the build (default: 8)")
        .describe('help', 'Print this help screen');

    var argv = optimist.argv;
    if (argv.help || argv.h) {
        optimist.showHelp();
        process.exit(0);
    }

    /* Create the build */
    var threads = argv.threads ? parseInt(argv.threads) : 8;
    var build = foraBuild.create({ threads: threads });

    /* The three configs */
    var sharedConfig = require('./shared/build-config')(foraBuild.tools);
    var serverConfig = require('./server/build-config')(foraBuild.tools);
    var clientConfig = require('./www-client/build-config')(foraBuild.tools);

    /* Set build parameters */
    build.state.monitor = !argv.norun;

    if (argv.client || argv.server) {
        build.state.buildClient = argv.client;    
        build.state.buildServer = argv.server;
    } else {
        build.state.buildClient = true;
        build.state.buildServer = true;
    }    

    build.state.debug = argv.debug;
    
    /* Create configuration */
    var shared = build.configure(sharedConfig, 'shared');
    if (build.state.buildServer)
        var server = build.configure(serverConfig, 'server');
    if (build.state.buildClient)
        var client = build.configure(clientConfig, 'www-client');

    build.job(function*() {
        if (this.state.monitor) {
            var params = ["server/run.sh"];
            if (build.state.debug) params.push("--debug");
            if (argv.debugapi) params.push("--debugapi");
            if (argv.debugweb) params.push("--debugweb");
            if (argv.debugclient) params.push("--debugclient");
            console.log("Restarting the server.....");
            var script = spawn("sh", params);
        }
    }, "restart_server");

    /* After all configs are built */
    build.onComplete(function*() {
        this.state.complete = true;

        var elapsed = Date.now() - start;

        var sharedTime = (shared.state.end - shared.state.start)/1000;
        console.log("Build(shared): " + sharedTime + "s");        
        
        if (this.state.buildServer) {
            var serverTime = (server.state.end - server.state.start)/1000;
            console.log("Build(server): " + serverTime + "s");        
        }
        if (this.state.buildClient) {
            var clientTime = (client.state.end - client.state.start)/1000;
            console.log("Build(client): " + clientTime + "s");
        }
        console.log("Build(total): " + (elapsed/1000) + "s");    
    });

    /* Monitor? */
    if (build.state.monitor) {
        build.onComplete(function*() {
            this.queue("restart_server");
        });
    }

    /* Start */
    build.start(build.state.monitor);
})();
