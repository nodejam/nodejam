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


    module.exports = function*(config) {
        var models = require('fora-app-models');

        /*
            Services
            1) Database Service
            2) Extensions Service
            3) Types Service
            4) Parser Service
            5) Auth Service
        */

        var services = require('fora-services');

        var baseConfiguration = require('fora-configuration');

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(baseConfiguration.db);
        services.add("db", db);

        //Extensions Service
        var ExtensionsService = require('fora-extensions-service');
        var extensionsService = new ExtensionsService(config.services.extensions, baseConfiguration.services.extensions);
        _ = yield* extensionsService.init();
        services.add("extensions", extensionsService);

        //Types Service
        var TypesService = require('fora-types-service');
        var typesService = new TypesService(extensionsService);
        _ = yield* typesService.init([models], models.Record);
        services.add("types", typesService);

        //Parser Service
        var parser = require('fora-requestparser-service')(typesService);
        services.add("parser", parser);

        //Auth Service
        var authService = require('fora-auth-service')(baseConfiguration, db);
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
        var koa = require('koa');
        var app = koa();

        var errorHandler = require('fora-error-handler');
        app.use(errorHandler);

        var container = yield* extensionsService.get(baseConfiguration.apiContainer);
        _ = yield* container.init();

        var router = yield* container.getRouter();
        app.use(router.start());

        /* GO! */
        app.listen(config.port);
    };
})();
