(function() {
    "use strict";

    var _;

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    //process.chdir(__dirname);

    var conf = require('../conf');
    var server = require('../lib/web/server');

    var ExtensionLoader = require('fora-extensions').Loader,
    var loader = new ExtensionLoader({
        extensionDirectories: [require("path").resolve(__dirname, '../extensions')],
        extensionTypes: {
            containers: ['api'],
            apps: ['api'],
            records: ['model']
        }
    });

    co(function*() {
        _ = yield* loader.init();
        _ = yield* server(conf.applicationContainer + ":api", loader, conf, host, port);
        logger.log("Fora API started at " + new Date() + " on " + host + ":" + port);
    })();

})();
