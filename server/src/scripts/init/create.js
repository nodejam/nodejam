(function() {

    "use strict";

    var _;

    var co = require('co'),
        logger = require('fora-app-logger'),
        fs = require('fs'),
        path = require('path'),
        FileService = require('fora-app-file-service'),
        initializeApp = require('fora-app-initialize'),
        services = require('fora-app-services'),
        baseConfig = require('../../config');

    var fileService = new FileService(baseConfig);

    //create directories
    var today = Date.now();
    ['assets', 'images', 'original-images'].forEach(function(p) {
        for(var i = 0; i <=999; i++) {
            var newPath = fileService.getDirPath(p, i.toString());
            if(!fs.existsSync(newPath)) {
                fs.mkdirSync(newPath);
                logger.log("Created " + newPath);
            } else {
                logger.log(newPath + " exists");
            }
        }
    });

    //ensure indexes.
    co(function*() {
        var config = {
            services: {
                extensions: {
                    modules: [
                        { kind: "container", modules: ["api", "web"] },
                        { kind: "app", modules: ["definition", "api"] },
                        { kind: "record", modules: ["definition", "model", "web"] }
                    ]
                }
            }
        };

        var initResult = yield* initializeApp(config, baseConfig);
        var db = services.getDb();
        var typesService = services.getTypesService();
        _ = yield* db.setupIndexes(typesService.getTypeDefinitions());

        console.log("wait for 3 seconds...");
        setTimeout(function() {
            console.log("done");
            process.exit();
        }, 5000);
    }).then(null, function(err) { console.log(err); });

})();
