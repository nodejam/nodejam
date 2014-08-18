(function() {
    "use strict";

    var _;

    var co = require('co');
    var logger = require('../common/logger');
    var server = require('../common/app-server');

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    var config = {
        services: {
            extensions: {
                types: ["app"]
            }
        },

        host: host,
        port: port
    };

    var container = require('./controllers');

    co(function*() {
        _ = yield* server(container, config);
        logger.log("Fora API started at " + new Date() + " on " + host + ":" + port);
    })();

})();
