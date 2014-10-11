(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    /*
        Setup information useful for monitoring and debugging
    */
    var setupInstanceStats = function() {
        var appInfo = {};
        var randomizer = require('fora-app-randomizer');
        appInfo.instance = randomizer.uniqueId();
        appInfo.since = Date.now();
        return appInfo;
    };


    var init = function*(config, baseConfig) {
        var appInfo = setupInstanceStats();
        /*
            Services
            0) Configuration
            1) Database Service
            2) Extensions Service
            3) Types Service
        */
        var models = require("fora-app-models");
        var services = require('fora-app-services');
        var foraModels = require('fora-models');

        //Configuration
        services.add("configuration", baseConfig);

        //Database Service
        var Database = require('fora-db');
        var db = new Database(baseConfig.db);
        services.add("db", db);

        /*
            Extensions Service
            ------------------
        */
        var ExtensionsService = require('fora-extensions-service');
        var extensionsService = new ExtensionsService(config.services.extensions, baseConfig.services.extensions);
        _ = yield* extensionsService.init();
        services.add("extensionsService", extensionsService);

        /*
            Types Service
            -------------
            We must pass all the typeDefinitions and virtual typeDefinitions to typesService.
            Virtual Type Definitions are defined in extensions, so we need to get it via extensionsService.
        */
        var TypesService = require('fora-app-types-service');
        var typesService = new TypesService(
            extensionsService,
            {
                modelServices: {
                    getRowId: db.getRowId.bind(db),
                    setRowId: db.setRowId.bind(db),
                    isModel: function(i) { return i instanceof foraModels.BaseModel; }
                }
            }
        );
        var typeDefinitions = Object.keys(models).map(function(k) { return models[k]; });

        var recordExtensions = yield* extensionsService.getModulesByKind("record", "definition");
        var recordVirtTypeDefinitions = Object.keys(recordExtensions).map(function(key) {
            return { typeDefinition: recordExtensions[key], ctor: models.Record };
        });

        _ = yield* typesService.init(typeDefinitions, recordVirtTypeDefinitions);
        services.add("typesService", typesService);

        return {
            appInfo: appInfo
        };
    };

    module.exports = init;

})();
