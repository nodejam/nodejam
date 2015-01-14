(function() {
    "use strict";

    var init = function*(config, baseConfig) {
        /*
            Services
            0) Configuration
            1) Database Service
            2) Extensions Service
            3) Types Service
        */
        var services = require('fora-lib-services');

        //Configuration
        services.setConfiguration(baseConfig);

        //Database Service
        var Database = require('fora-lib-db-backend');
        var db = new Database(baseConfig.db);
        services.setDb(db);

        /*
            Extensions Service
            ------------------
        */
        var ExtensionsService = require('fora-extensions-service');
        var fnModuleMapper = function*(extModule, kind, typeName, version, moduleName) {
            if ((kind === "record" || kind === "app") && moduleName === "definition") {
                extModule.schema.id = kind + "_" + typeName + "_" + version;
            }
            if (extModule.init)
                yield* extModule.init();

            return extModule;
        };
        var extensionsService = new ExtensionsService(config.services.extensions, baseConfig.services.extensions, fnModuleMapper);
        yield* extensionsService.init();
        services.setExtensionsService(extensionsService);

        /*
            Types Service
            -------------
            We must pass all the entitySchemas and virtual entitySchemas to typesService.
            Virtual Type Definitions are defined in extensions, so we need to get it via extensionsService.
        */
        var TypesService = require('fora-lib-types-service');
        var typesService = new TypesService();
        services.setTypesService(typesService);

        var models = require("fora-lib-models");

        var modelsArray = Object.keys(models).map(function(k) { return models[k]; });
        var entitySchemas = modelsArray.map(function(ctor) {
            var entitySchema = ctor.entitySchema;
            entitySchema.ctor = ctor;
            return entitySchema;
        });

        var appExtensions = yield* extensionsService.getExtensionsByKind("app");
        var appVirtEntitySchemas = [].concat.apply([], Object.keys(appExtensions).map(function(type) {
            var versions = appExtensions[type];
            return Object.keys(versions).map(function(version) {
                var ext = versions[version];
                ext.definition.ctor = ext.model;
                return ext.definition;
            });
        }));

        var recordExtensions = yield* extensionsService.getExtensionsByKind("record");
        var recordVirtEntitySchemas = [].concat.apply([], Object.keys(recordExtensions).map(function(type) {
            var versions = recordExtensions[type];
            return Object.keys(versions).map(function(version) {
                var ext = versions[version];
                ext.definition.ctor = ext.model;
                return ext.definition;
            });
        }));

        yield* typesService.init(
            entitySchemas,
            [
                { entitySchemas: appVirtEntitySchemas, baseEntitySchema: models.App.entitySchema },
                { entitySchemas: recordVirtEntitySchemas, baseEntitySchema: models.Record.entitySchema }
            ]
        );

        return {};
    };

    module.exports = init;

})();
