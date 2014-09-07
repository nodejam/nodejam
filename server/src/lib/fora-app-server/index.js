(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    /*
        Setup information useful for monitoring and debugging
    */
    var setupInstanceStats = function() {
        var appInfo = {};
        if (process.env.NODE_ENV === 'development') {
            var randomizer = require('fora-app-randomizer');
            appInfo.instance = randomizer.uniqueId();
            appInfo.since = Date.now();
        } else {
            appInfo.instance = '00000000';
            appInfo.since = 0;
        }
        return appInfo;
    };


    module.exports = function*(routes, config, baseConfig) {
        /*
            Setup information useful for monitoring and debugging
        */
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

        //Configuration
        services.add("configuration", baseConfig);

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(baseConfig.db);
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
        var TypesService = require('fora-types-service');
        var typesService = new TypesService(extensionsService);
        var typeDefinitions = Object.keys(models).map(function(k) { return models[k]; });
        var exts = yield* extensionsService.getModulesByKind("record", "definition");
        var virtualTypeDefinitions = Object.keys(exts).map(function(key) {
            return { typeDefinition: exts[key], ctor: models.Record };
        });
        _ = yield* typesService.init(typeDefinitions, virtualTypeDefinitions);
        services.add("typesService", typesService);

        /*
            Start the app.
            1) Error Handling
            2) routes Initialization
            3) Start Routing
        */
        var koa = require('koa');
        var app = koa();

        var errorHandler = require('fora-app-error-handler');
        app.use(errorHandler);

        for (let i = 0; i < routes.length; i++) {
            _ = yield* routes[i].init(appInfo);
            var router = yield* routes[i].getRouter();
            app.use(router.route());
        }

        /* GO! */
        app.listen(config.port);
    };
})();
