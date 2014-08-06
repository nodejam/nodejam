(function() {
    "use strict";

    var services = require("fora-services");
    var ForaTypesServiceBase = require('./fora-types-service-base');

    var ForaTypesService = function() {
        ForaTypesServiceBase.apply(this, arguments);
    };

    ForaTypesService.prototype = Object.create(ForaTypesServiceBase.prototype);
    ForaTypesService.prototype.constructor = ForaTypesService;

    ForaTypesService.prototype.addTrustedUserTypes = function*(ctor, baseTypeName, dir, definitions) {
        var extensionsService = services.get("extensions");
        var extensions = extensionsService.getTrustedExtensions("records");

        for (var name in extensions) {
            definitions[name.split(":")[0]] = extensions[name];
        }
    };

    module.exports = ForaTypesService;

})();
