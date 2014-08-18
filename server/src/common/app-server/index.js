(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    /*
        Setup information useful for monitoring and debugging
    */
    var setupInstanceStats = function() {
        var appInfo = {};
        if (process.env.NODE_ENV === 'development') {
            var randomizer = require('fora-randomizer');
            appInfo.instance = randomizer.uniqueId();
            appInfo.since = Date.now();
        } else {
            appInfo.instance = '00000000';
            appInfo.since = 0;
        }
        return appInfo;
    };


    module.exports = function*(container, config) {
        /*
            Services
            1) Database Service
            2) Extensions Service
            3) Types Service
        */
        var baseConfig = require("../../config");
        var models = require("../../models");

        var services = require('../fora-services');

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(baseConfig.db);
        services.add("db", db);

        //Extensions Service
        var ExtensionsService = require('fora-extensions-service');
        var extensionsService = new ExtensionsService(config.services.extensions, baseConfig.services.extensions);
        _ = yield* extensionsService.init();
        services.add("extensions", extensionsService);

        //Types Service
        var TypesService = require('fora-types-service');
        var typesService = new TypesService(extensionsService);
        var virtualTypeDefinitions = yield* typesService.getVirtualTypeDefinitions();
        _ = yield* typesService.init(
            Object.keys(models).map(function(k) { return models[k]; }),
            virtualTypeDefinitions
        );
        services.add("types", typesService);

        /*
            Setup information useful for monitoring and debugging
        */
        var appInfo = setupInstanceStats();

        /*
            Start the app.
            1) Error Handling
            2) Container Initialization
            3) Start Routing
        */
        var koa = require('koa');
        var app = koa();

        var errorHandler = require('../error-handler');
        app.use(errorHandler);

        _ = yield* container.init();

        var router = yield* container.getRouter();
        app.use(router.route());

        /* GO! */
        app.listen(config.port);
    };
})();
