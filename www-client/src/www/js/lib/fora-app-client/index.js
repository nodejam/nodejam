(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    /*
        Setup information useful for monitoring and debugging
    */
    var Client = function(config) {
        this.config = config;
    };


    Client.prototype.init = function*() {
        var models = require("fora-app-models");

        var services = require('fora-app-services');

        /*
            Extensions Service
            ------------------
        */
        var ExtensionsService = require('fora-extensions-service');
        var extensionsService = new ExtensionsService(this.config.services.extensions);
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

    module.exports = Client;
})();
