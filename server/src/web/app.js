(function() {
    "use strict";

    var _;

    var co = require('co');
    var logger = require('fora-app-logger');
    var server = require('fora-app-server');
    var baseConfig = require('../config');

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    var config = {
        services: {
            extensions: {
                modules: [
                    { kind: "app", modules: ["web"] },
                    { kind: "record", modules: ["definition", "model"] }
                ]
            }
        },

        host: host,
        port: port
    };

    var container = require('./controllers');

    co(function*() {
        _ = yield* server(container, config, baseConfig);
        logger.log("Fora Website started at " + new Date() + " on " + host + ":" + port);
    })();

})();
