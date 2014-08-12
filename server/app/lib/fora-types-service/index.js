(function() {
    "use strict";

    var ForaTypesServiceBase = require('./fora-types-service-base');

    var ForaTypesService = function(extensionsService) {
        this.extensionsService = extensionsService;
        ForaTypesServiceBase.apply(this);
    };

    ForaTypesService.prototype = Object.create(ForaTypesServiceBase.prototype);
    ForaTypesService.prototype.constructor = ForaTypesService;

    ForaTypesService.prototype.addTrustedUserTypes = function*(ctor, baseTypeName, dir, definitions) {
        var extensions = this.extensionsService.getTrustedExtensions("records");

        for (var name in extensions) {
            definitions[name.split(":")[0]] = extensions[name];
        }
    };

    module.exports = ForaTypesService;

})();
