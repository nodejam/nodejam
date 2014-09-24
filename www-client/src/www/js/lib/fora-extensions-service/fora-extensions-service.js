(function() {
    "use strict";

    var _;

    var moduleCache = {};
    var extensionsByName = {};
    var extensionsByKind = {};
    var extensionsByModule = {};

    var ExtensionsService = function(config, dynamicExtensionFinder) {
        this.config = config;
        this.dynamicExtensionFinder = dynamicExtensionFinder;
    };


    ExtensionsService.prototype.init = function*() {
        return;
        yield false;
    };


    ExtensionsService.prototype.getModule = function*(name) {
        return moduleCache[name];
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
