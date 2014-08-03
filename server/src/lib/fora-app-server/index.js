(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    /*
        Setup information useful for monitoring and debugging
    */
    var setupInstanceStats = function() {
        var appInfo = {};
        if (process.env.NODE_ENV === 'development') {
            var randomizer = require('../randomizer');
            appInfo.instance = randomizer.uniqueId();
            appInfo.since = Date.now();
        } else {
            appInfo.instance = '00000000';
            appInfo.since = 0;
        }
        return appInfo;
    };


    module.exports = function*(config) {
        var models = require('app-models'),
            fields = require('app-fields');

        var services = require('fora-services');

        /*
            Services
            0) Config
            1) Database Service
            2) Extensions Service
            3) Types Service
            4) Parser Service
            5) Auth Service
        */

        //Config is also a service.
        services.add("configuration", config);

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(config.baseConfiguration.db);
        services.add("db", db);

        //Extensions Service
        var extensionsService = require('fora-extensions-service')(config.extensionsService, config.baseConfiguration.extensionsService);
        _ = yield* extensionsService.init();
        services.add("extensions", extensionsService);

        //Types Service
        var TypesService = require('fora-types-service');
        var typesService = new TypesService();
        _ = yield* typesService.init([models, fields], models.Record);
        services.add("types", typesService);

        //Parser Service
        var parserService = require('fora-requestparser-service');
        services.add("parser", parserService);

        //Auth Service
        var authService = require('fora-auth-service');
        services.add("auth", authService);

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
        var app = koa();

        var errorHandler = require('fora-error-handler');
        app.use(errorHandler);

        var container = yield* extensionsService.load(config.baseConfiguration.applicationContainer + ":" + containerModuleName);
        _ = yield* container.init(context);

        var router = yield* container.getRouter();
        app.use(router.getRoutes());

        /* GO! */
        app.listen(config.port);
    };
})();
