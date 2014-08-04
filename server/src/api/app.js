(function() {
    "use strict";

    var _;

    var co = require('co')
    var logger = require('fora-logger');
    var server = require('fora-app-server');

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    var config = {
        baseConfiguration: require('../conf'),

        /* Extensions needed by this app */
        services: {
            extensions: {
                types: {
                    containers: ['api'],
                    apps: ['api'],
                    records: ['model']
                }
            }
        },

        /*
            App server will start applicationContainer:containerModuleName
            For example: containers/fora/1.0.0:api
        */
        containerModuleName: "api",

        host: host,
        port: port
    };

    co(function*() {
        _ = yield* server(config);
        logger.log("Fora API started at " + new Date() + " on " + host + ":" + port);
    })();

})();
