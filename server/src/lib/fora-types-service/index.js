(function() {
    "use strict";

    var ForaTypesServiceBase = require('./fora-types-service-base');

    var ForaTypesService = function(extensionsService) {
        this.extensionsService = extensionsService;
        ForaTypesServiceBase.apply(this);
    };

    ForaTypesService.prototype = Object.create(ForaTypesServiceBase.prototype);
    ForaTypesService.prototype.constructor = ForaTypesService;


    ForaTypesService.prototype.addTrustedTypes = function*(ctor, type, dir, definitions) {
        var extensions = this.extensionsService.getTrustedExtensions(type);

        for (var name in extensions) {
            definitions[name] = extensions[name];
        }
    };


    module.exports = ForaTypesService;

})();
