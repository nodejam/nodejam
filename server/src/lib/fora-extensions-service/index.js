(function() {
    "use strict";

    var _;

    var thunkify = require('fora-node-thunkify'),
        fs = require('fs'),
        path = require('path');

    var readdir = thunkify(fs.readdir);
    var stat = thunkify(fs.stat);
    var readfile = thunkify(fs.readFile);

    var moduleCache = {};
    var extensionsByType = {};
    var extensionsByName = {};

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

        var findTrustedExtensions = function*(baseDirectory, extensionType) {
            var typeNames = yield* getSubDirectories(path.join(baseDirectory, extensionType));
            for(var i = 0; i < typeNames.length; i++) {
                var typeName = typeNames[i];
                var versions = yield* getSubDirectories(path.join(baseDirectory, extensionType, typeName));
                for(var j = 0; j < versions.length; j++) {
                    var version = versions[j];
                    var modules = yield* getSubDirectories(path.join(baseDirectory, extensionType, typeName, version));
                    for(var k = 0; k < modules.length; k++) {
                        var moduleName = modules[k];
                        var extensionName = extensionType + "/" + typeName + "/" + version;
                        var fullName = extensionName + "/" + moduleName;
                        var extModule = require(path.join(baseDirectory, extensionType, typeName, version, moduleName));

                        //Put the module in cache
                        moduleCache[fullName] = extModule;

                        //Add to by-extension-name directory
                        if (!extensionsByName[extensionName])
                            extensionsByType[extensionName] = {};
                        extensionsByType[extensionName][moduleName] = extModule;

                        //Add to by-type directory
                        if (!extensionsByType[extensionType])
                            extensionsByType[extensionType] = {};
                        extensionsByType[extensionType][fullName] = extModule;
                    }
                }
            }
        };

        for(var i = 0; i < this.baseConfig.locations.length; i++) {
            for(var j = 0; j < this.config.types.length; j++) {
                _ = yield* findTrustedExtensions(this.baseConfig.locations[i], this.config.types[j]);
            }
        }
    };


    ExtensionsService.prototype.get = function*(name) {
        var extension = moduleCache[name];
        if (extension)
            return extension;
        else
            throw new Error("Extension " + name + " was not found");
    };


    ExtensionsService.prototype.getTrustedExtensions = function(type) {
        return extensionsByType[type];
    };


    module.exports = ExtensionsService;

})();
