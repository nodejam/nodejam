(function() {
    "use strict";

    var co = require('co'),
        logger = require('fora-app-logger'),
        fs = require('fs'),
        path = require('path'),
        FileService = require('fora-app-file-service'),
        models = require('fora-app-models'),
        conf = require('../../config');

    var fileService = new FileService(conf);

    //create directories
    var today = Date.now();
    ['assets', 'images', 'original-images'].forEach(function(p) {
        for(var i = 0; i <=999; i++) {
            (function(i) {
                var newPath = fileService.getDirPath(p, i.toString());
                fs.exists(newPath, function(exists) {
                    if (!exists) {
                        fs.mkdir(newPath, function() {});
                        logger.log("Created " + newPath);
                    } else {
                        logger.log(newPath + " exists");
                    }
                });
            })(i);
        }
    });

    //ensure indexes.
    (co(function*() {
        var Database = require('fora-db');
        var db = new Database(conf.db);

        _ = yield* typesService.init([models, fields], models.App, models.Record);
            _ = yield* db.setupIndexes(typesService.getTypeDefinitions());

        console.log("wait for 5 seconds...");
        setTimeout(function() {
            console.log("done");
            process.exit();
        }, 5000);
    }))();

})();
