(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    var ForaRequest = require('fora-request');

    /*
        Setup information useful for monitoring and debugging
    */
    var Client = function(config, baseConfig) {
        this.config = config;
        this.baseConfig = baseConfig;
    };


    Client.prototype.init = function*() {
        var models = require("fora-app-models");

        var services = require('fora-app-services');


        //Configuration
        services.add("configuration", this.baseConfig);

        //Database Service
        var odm = require('fora-models');
        var db = new odm.Database(this.baseConfig.db);
        services.add("db", db);

        
        /*
            Extensions Service
            ------------------
        */
        var ExtensionsService = require('fora-extensions-service');
        var extensionsService = new ExtensionsService(this.config.services.extensions, this.baseConfig);
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

        var recordExtensions = yield* extensionsService.getModulesByKind("record", "definition");
        var recordVirtTypeDefinitions = Object.keys(recordExtensions).map(function(key) {
            return { typeDefinition: recordExtensions[key], ctor: models.Record };
        });

        _ = yield* typesService.init(typeDefinitions, recordVirtTypeDefinitions);
        services.add("typesService", typesService);

    };


    Client.prototype.addRouter = function(router) {
        var routeFunc = router.route();

        var doRouting = function*() {
            var request = new ForaRequest();
            _ = yield* routeFunc.call(request, null);
        };

        var onChange = function() {
            co(doRouting)();
        };

        // Listen on hash change:
        window.addEventListener('hashchange', onChange);
        // Listen on page load:
        window.addEventListener('load', onChange);
    };


    Client.prototype.listen = function() {
        /* PASS */
        console.log("Fora initialized.");
    };





    module.exports = Client;

})();
