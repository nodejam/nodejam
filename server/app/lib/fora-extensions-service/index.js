(function() {
    "use strict";

    var _;

    var thunkify = require('fora-node-thunkify'),
        fs = require('fs'),
        path = require('path');

    var readdir = thunkify(fs.readdir);
    var stat = thunkify(fs.stat);
    var readfile = thunkify(fs.readFile);

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
                var filePath = dir + "/" + files[i];
                var entry = yield* stat(filePath);
                if (entry.isDirectory())
                    dirs.push(files[i]);
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

        for(var i = 0; i < this.baseConfig.locations.length; i++) {
            for(var type in this.config.types) {
                var modules = this.config.types[type];
                for(var j = 0; j < modules.length; j++) {
                    _ = yield* findTrustedExtensions(this.baseConfig.locations[i], type, modules[j]);
                }
            }
        }
    };


    ExtensionsService.prototype.get = function*(name) {
        var extension = trustedExtensionCache[name];
        if (extension)
            return extension;
        else
            throw new Error("Extension " + name + " was not found");
    };


    ExtensionsService.prototype.getTrustedExtensions = function(type) {
        return extensionTypeCache[type];
    };


    module.exports = ExtensionsService;

})();
