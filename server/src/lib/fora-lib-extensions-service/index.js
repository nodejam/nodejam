(function() {

    "use strict";

    var promisify = require('nodefunc-generatorify'),
        fs = require('fs'),
        path = require('path');

    var readdir = promisify(fs.readdir);
    var stat = promisify(fs.stat);
    var readfile = promisify(fs.readFile);

    var moduleCache = {};
    var extensionsDir = {};

    var ExtensionsService = function(config, baseConfig, fnModuleMapper, dynamicExtensionFinder) {
        this.config = config;
        this.baseConfig = baseConfig;
        this.fnModuleMapper = fnModuleMapper;
        this.dynamicExtensionFinder = dynamicExtensionFinder;
    };


    ExtensionsService.prototype.init = function*() {
        var self = this;

        var getSubDirectories = function*(dir) {
            var dirs = [];
            var files = yield readdir(dir);
            for (var i = 0; i < files.length; i++) {
                var filePath = dir + "/" + files[i];
                var entry = yield stat(filePath);
                if (entry.isDirectory())
                    dirs.push(files[i]);
            }
            return dirs;
        };

        var findTrustedExtensions = function*(baseDirectory, kind, modules) {
            var typeNames = yield getSubDirectories(path.join(baseDirectory, kind));
            for(var i = 0; i < typeNames.length; i++) {
                var typeName = typeNames[i];
                var versions = yield getSubDirectories(path.join(baseDirectory, kind, typeName));
                for(var j = 0; j < versions.length; j++) {
                    var version = versions[j];
                    for(var k = 0; k < modules.length; k++) {
                        var moduleName = modules[k];
                        var extensionName = kind + "_" + typeName + "_" + version;
                        var fullName = extensionName + "_" + moduleName;

                        var extModule = require(path.join(baseDirectory, kind, typeName, version, moduleName));
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
            }
        };

        for(var i = 0; i < this.baseConfig.locations.length; i++) {
            for(var j = 0; j < this.config.modules.length; j++) {
                yield findTrustedExtensions(
                    this.baseConfig.locations[i],
                    this.config.modules[j].kind,
                    this.config.modules[j].modules
                );
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
