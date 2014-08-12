(function() {
    "use strict";

    var _;

    var co = require('co')
    var logger = require('fora-logger');
    var server = require('../common/fora-app-server');

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    var config = {
        services: {
            extensions: {
                types: []
                /* types: ["app", "record"] */
            }
        },

        host: host,
        port: port
    };

    var container = require('./controllers');

    co(function*() {
        _ = yield* server(container, config);


_ = yield* container.init();


        logger.log("Fora API started at " + new Date() + " on " + host + ":" + port);
    })();

})();
