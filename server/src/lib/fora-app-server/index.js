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

        var context = { services: {} };

        /*
            Load Services
            1) Database Service
            2) Extensions Service
            3) Types Service
            4) Parser Service
            5) Auth Service
        */

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(config.baseConfiguration.db);
        context.services.db = db;

        //Extensions Service
        var extensionsService = require('fora-extensions-service')(config.extensionsService, config.baseConfiguration.extensionsService);
        _ = yield* extensionsService.init();
        context.services.extensionsService = extensionsService;

        //Types Service
        var TypesService = require('fora-types-service');
        var typesService = new TypesService();
        context.services.typesService = typesService;
        _ = yield* typesService.init([models, fields], models.Record, context);

        //Parser Service
        var parserService = require('fora-requestparser-service')(context);
        context.services.parserService = parserService;

        //Auth Service
        var authService = require('fora-auth-service')(context);
        context.services.authService = authService;

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
        app.use(router.start());

        /* GO! */
        app.listen(config.port);
    };
})();
