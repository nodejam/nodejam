(function() {
    "use strict";

    var optimist = require('optimist')
        .usage('Build the fora project.\nUsage: $0')
        .alias('h', 'help')
        .describe('client', "Build the client")
        .describe('server', "Build the server")
        .describe('no-monitor', "Do not start the server or monitor files after building")
        .describe('no-run', "Do not start the server after building")
        .describe('threads', "Number of threads to use for the build (default: 8)")
        .describe('debug-api', 'Start debugger for api')
        .describe('debug-brk-api', 'Start debugger for api with breakpoint')
        .describe('debug-web', 'Start debugger for web')
        .describe('debug-brk-web', 'Start debugger for web with breakpoint')
        .describe('debug-build', 'Debug the build process itself')
        .describe('debug-client', 'Do not minify JS files sent to browser')
        .describe('show-errors', 'Display errors in the console')
        .describe('args-some-param', 'Pass some-param to web and api processes')
        .describe('use-es6', 'Use es6 generators in browser (skips transpiler)')
        .describe('help', 'Print this help screen');

    var argv = optimist.argv;
    if (argv.help || argv.h) {
        optimist.showHelp();
        process.exit(0);
    }

    GLOBAL.ENABLE_DEBUG_MODE = argv['debug-build'];

    var start = Date.now();

    var foraBuild = require('fora-build');
    var spawn = foraBuild.tools.process.spawn({ log: function(data) { process.stdout.write(data); } });

    /* Create the build */
    var threads = argv.threads ? parseInt(argv.threads) : 8;
    var build = foraBuild.create({ threads: threads });

    /* The three configs */
    var sharedConfig = require('./shared/build-config')(foraBuild.tools);
    var serverConfig = require('./server/build-config')(foraBuild.tools);
    var clientConfig = require('./www-client/build-config')(foraBuild.tools);

    /* Set build parameters */
    build.state.monitor = true;
    build.state.run = true;
    if (argv.monitor === false) {
        build.state.monitor = false;
        build.state.run = false;
    }
    if (argv.run === false) {
        build.state.run = false;
    }

    if (argv.client || argv.server) {
        build.state.buildClient = argv.client;
        build.state.buildServer = argv.server;
    } else {
        build.state.buildClient = true;
        build.state.buildServer = true;
    }

    if (argv['debug-api'] || argv['debug-brk-api']) build.state.debugApi = true;
    if (argv['debug-web'] || argv['debug-brk-web']) build.state.debugWeb = true;
    if (argv['debug-client']) build.state.debugClient = true;
    if (argv['use-es6']) build.state.useES6 = true;

    /* Create configuration */
    var shared = build.configure(sharedConfig, 'shared');
    if (build.state.buildServer)
        var server = build.configure(serverConfig, 'server');
    if (build.state.buildClient)
        var client = build.configure(clientConfig, 'www-client');

    build.job(function*() {
        if (this.state.run) {
            var params = ["server/run.sh"];
            if (argv['debug-api']) params.push("--debug-api");
            if (argv['debug-brk-api']) params.push("--debug-brk-api");
            if (argv['debug-web']) params.push("--debug-web");
            if (argv['debug-brk-web']) params.push("--debug-brk-web");
            if (argv['debug-client']) params.push("--debug-client");
            if (argv['show-errors']) params.push("--show-errors");
            var moreArgs = process.argv.filter(function(p) { return /^--args-/.test(p); }).map(function(p) { return p.replace(/^--args-/, '--'); });
            params = params.concat(moreArgs);
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
            if (build.state.run)
                this.queue("restart_server");
        });
    }

    /* Start */
    try {
        build.start(build.state.monitor);
    } catch(e) {
        console.log(e.stack);
        if (e._inner) console.log(e._inner.stack);
    }
})();
