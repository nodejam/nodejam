(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*


    var init = function*(config, baseConfig) {
        /*
            Services
            0) Configuration
            1) Database Service
            2) Extensions Service
            3) Types Service
        */
        var services = require('fora-app-services');

        //Configuration
        services.setConfiguration(baseConfig);

        //Database Service
        var Database = require('fora-app-db-backend');
        var db = new Database(baseConfig.db);
        services.setDb(db);

        /*
            Extensions Service
            ------------------
        */
        var ExtensionsService = require('fora-extensions-service');
        var fnModuleMapper = function*(extModule, kind, typeName, version, moduleName) {
            if ((kind === "record" || kind === "app") && moduleName === "definition") {
                extModule.name = kind + "/" + typeName + "/" + version;
            }
            if (extModule.init)
                _ = yield* extModule.init();

            return extModule;
        };
        var extensionsService = new ExtensionsService(config.services.extensions, baseConfig.services.extensions, fnModuleMapper);
        _ = yield* extensionsService.init();
        services.setExtensionsService(extensionsService);

        /*
            Types Service
            -------------
            We must pass all the typeDefinitions and virtual typeDefinitions to typesService.
            Virtual Type Definitions are defined in extensions, so we need to get it via extensionsService.
        */
        var TypesService = require('fora-app-types-service');
        var typesService = new TypesService();
        services.setTypesService(typesService);

        var models = require("fora-app-models");

        var modelsArray = Object.keys(models).map(function(k) { return models[k]; });
        var typeDefinitions = modelsArray.map(function(ctor) {
            var typeDefinition = ctor.typeDefinition;
            typeDefinition.ctor = ctor;
            return typeDefinition;
        });

        var appExtensions = yield* extensionsService.getExtensionsByKind("app");
        var appVirtTypeDefinitions = [].concat.apply([], Object.keys(appExtensions).map(function(type) {
            var versions = appExtensions[type];
            return Object.keys(versions).map(function(version) {
                var ext = versions[version];
                ext.definition.ctor = ext.model;
                return ext.definition;
            });
        }));

        var recordExtensions = yield* extensionsService.getExtensionsByKind("record");
        var recordVirtTypeDefinitions = [].concat.apply([], Object.keys(recordExtensions).map(function(type) {
            var versions = recordExtensions[type];
            return Object.keys(versions).map(function(version) {
                var ext = versions[version];
                ext.definition.ctor = ext.model;
                return ext.definition;
            });
        }));

        _ = yield* typesService.init(
            typeDefinitions,
            [
                { typeDefinitions: appVirtTypeDefinitions, baseTypeDefinition: models.App.typeDefinition },
                { typeDefinitions: recordVirtTypeDefinitions, baseTypeDefinition: models.Record.typeDefinition }
            ]
        );

        return {};
    };

    module.exports = init;

})();
