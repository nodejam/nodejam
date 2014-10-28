(function() {
    "use strict";

    var _;

    var moduleCache = {};
    var extensionsByName = {};
    var extensionsByKind = {};
    var extensionsByModule = {};

    //This file was written out during the build...
    var extensionPaths = require('../../extensions/extensions');

    var ExtensionsService = function(config, baseConfig, fnModuleMapper, dynamicExtensionFinder) {
        this.config = config;
        this.baseConfig = baseConfig;
        this.fnModuleMapper = fnModuleMapper;
        this.dynamicExtensionFinder = dynamicExtensionFinder;
    };


    ExtensionsService.prototype.init = function*() {
        var self = this;

        var canLoad = function(m) { return m.kind === kind && m.modules.indexOf(moduleName) > -1; };

        for(var i = 0; i < extensionPaths.length; i++) {
            var path = extensionPaths[i].split('/').slice(2);
            var kind = path[0];
            var typeName = path[1];
            var version = path[2];
            var moduleName = path.slice(3).join("/");

            if (this.config.modules.some(canLoad)) {
                var extensionName = kind + "/" + typeName + "/" + version;
                var fullName = extensionName + "/" + moduleName;

                var extModule = require(["/extensions", kind, typeName, version, moduleName].join("/"));
                extModule = yield* self.fnModuleMapper(extModule, kind, typeName, version, moduleName);

                //Put the module in cache
                moduleCache[fullName] = extModule;

                //Add to by-extension-name directory
                if (!extensionsByName[extensionName])
                    extensionsByName[extensionName] = {};
                extensionsByName[extensionName][moduleName] = extModule;

                //Add to by-type directory
                if (!extensionsByKind[kind])
                    extensionsByKind[kind] = {};
                extensionsByKind[kind][fullName] = extModule;

                //Add to by-kind-and-module directory
                if (!extensionsByModule[kind])
                    extensionsByModule[kind] = {};
                if (!extensionsByModule[kind][moduleName])
                    extensionsByModule[kind][moduleName] = {};
                extensionsByModule[kind][moduleName][fullName] = extModule;
            }
        }
    };


    ExtensionsService.prototype.getModule = function*(name) {
        return moduleCache[name];
    };


    ExtensionsService.prototype.getModuleByFullType = function*(type, moduleName) {
        return moduleCache[type + "/" + moduleName];
    };


    ExtensionsService.prototype.getModuleByName = function*(kind, type, version, moduleName) {
        return moduleCache[kind + "/" + type + "/" + version + "/" + moduleName];
    };


    ExtensionsService.prototype.getModulesByKind = function*(kind, moduleName) {
        return extensionsByModule[kind][moduleName];
    };


    ExtensionsService.prototype.getExtensionsByKind = function*(kind) {
        return extensionsByKind[kind];
    };


    ExtensionsService.prototype.get = function*(name) {
        var extension = extensionsByName[name];
        return {
            trusted: extension ? true : false,
            extension: extension || this.dynamicExtensionFinder(name)
        };
    };


    module.exports = ExtensionsService;

})();
