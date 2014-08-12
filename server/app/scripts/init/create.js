(function() {
    "use strict";

    var co = require('co'),
        conf = require('fora-configuration'),
        logger = require('fora-logger'),
        fs = require('fs'),
        path = require('path'),
        FileService = require('fora-file-service'),
        models = require('fora-app-models');

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
        var odm = require('fora-models');
        _ = yield* typesService.init([models, fields], models.App, models.Record);

        var db = new odm.Database(conf.db);
        _ = yield* db.setupIndexes(typesService.getTypeDefinitions());

        console.log("wait for 5 seconds...");
        setTimeout(function() {
            console.log("done");
            process.exit();
        }, 5000);
    }))();

})();
