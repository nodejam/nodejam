(function() {
    "use strict";

    var _;

    var moduleCache = {};
    var extensionsDir = {};

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
            var moduleName = path.slice(3).join("_");

            if (this.config.modules.some(canLoad)) {
                var extensionName = kind + "_" + typeName + "_" + version;
                var fullName = extensionName + "_" + moduleName;

                var extModule = require(["/extensions", kind, typeName, version, moduleName].join("/"));
                extModule = yield self.fnModuleMapper(extModule, kind, typeName, version, moduleName);

                //Put the module in cache
                moduleCache[fullName] = extModule;

                //Add to by-extension-name directory
                if (!extensionsDir[kind])
                    extensionsDir[kind] = {};
                if (!extensionsDir[kind][typeName])
                    extensionsDir[kind][typeName] = {};
                if (!extensionsDir[kind][typeName][version])
                    extensionsDir[kind][typeName][version] = {};

                extensionsDir[kind][typeName][version][moduleName] = extModule;
            }
        }
    };


    ExtensionsService.prototype.getModule = function*(kind, type, version, moduleName) {
        return moduleCache[kind + "_" + type + "_" + version + "_" + moduleName];
    };


    ExtensionsService.prototype.getModuleByName = function*(name) {
        return moduleCache[name];
    };


    ExtensionsService.prototype.getModuleByFullType = function*(fullType, moduleName) {
        return moduleCache[fullType + "_" + moduleName];
    };


    ExtensionsService.prototype.getExtensionsByKind = function*(kind) {
        return extensionsDir[kind];
    };


    ExtensionsService.prototype.get = function*(name) {
        var extension;

        var arrID = name.split("_");
        var extTypes = extensionsDir[arrID[0]];
        if (extTypes) {
            var extVersions = extTypes[arrID[1]];
            if (extVersions)
                extension = extVersions[arrID[2]];
        }

        return {
            trusted: extension ? true : false,
            extension: extension || this.dynamicExtensionFinder(name)
        };
    };


module.exports = ExtensionsService;
})();
