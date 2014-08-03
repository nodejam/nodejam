(function() {
    "use strict";

    var _;

    var trustedExtensionCache = {};
    var extensionTypeCache = {};


    var ExtensionsService = function(config, baseConfig) {
        this.config = config;
        this.baseConfig = baseConfig;
    };


    ExtensionsService.prototype.init = function*() {

        var getSubDirectories = function*(dir) {
            var dirs = [];
            var files = yield* readdir(dir);
            for (var i = 0; i < files.length; i++) {
                var filePath = dir + "/" + file;
                var entry = yield* stat(filePath);
                if (entry.isDirectory())
                    dirs.push(file);
            }
            return dirs;
        };

        var findTrustedExtensions = function*(baseDirectory, extensionType, moduleName) {
            var typeNames = yield* getSubDirectories(path.join(baseDirectory, extensionType));
            for(var i = 0; i < typeNames.length; i++) {
                var typeName = typeNames[i];
                var versions = yield* getSubDirectories(path.join(baseDirectory, extensionType, typeName));
                for(var j = 0; j < versions.length; j++) {
                    var version = versions[j];
                    var extensionName = extensionType + "/" + typeName + "/" + version + ":" + moduleName;
                    var extModule = require(path.join(baseDirectory, extensionType, typeName, version, moduleName));
                    trustedExtensionCache[extensionName] = extModule;
                    if (!extensionTypeCache[extensionType])
                        extensionTypeCache[extensionType] = {};
                    extensionTypeCache[extensionType][extensionName] = extModule;
                }
            }
        };

        for(var i = 0; i < this.baseConfig.extensionsDirectories; i++) {
            for(var type in this.config.types) {
                var extensionType = this.config.types[type];
                for(var j = 0; j < types.length; j++) {
                    _ = yield* findTrustedExtensions(this.baseConfig.extensionsDirectories[i], extensionType, types[j]);
                }
            }
        }
    };


    ExtensionsService.prototype.load = function*(name) {
        var extension = trustedExtensionCache[name];
        if (extension)
            return extension;
        else
            throw new Error("Untrusted extensions are not implemented");
    };


    ExtensionsService.prototype.getTrustedExtensions = function(type) {
        return extensionTypeCache[type];
    };


    module.exports = ExtensionsService;

})();
