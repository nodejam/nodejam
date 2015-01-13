(function() {

    "use strict";

    var _;

    var co = require('co'),
        logger = require('fora-lib-logger'),
        fs = require('fs'),
        path = require('path'),
        FileService = require('fora-lib-file-service'),
        initializeApp = require('fora-lib-initialize'),
        services = require('fora-lib-services'),
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
        try {
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

            var initResult = yield initializeApp(config, baseConfig);
            var db = services.getDb();
            var typesService = services.getTypesService();
            yield db.setupIndexes(typesService.getEntitySchemas());
        } catch (err) {
            console.log(err.stack);
        }
        console.log("wait for 3 seconds...");
        setTimeout(function() {
            console.log("done");
            process.exit();
        }, 5000);
    }).then(null, function(err) { console.trace(err); });

})();
