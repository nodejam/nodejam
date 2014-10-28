(function() {
    "use strict";

    var ForaTypesService = require('fora-types-service');

    var ForaAppTypesService = function(extensionsService, services) {
        this.extensionsService = extensionsService;
        ForaTypesService.call(this, services);
    };

    ForaAppTypesService.prototype = Object.create(ForaTypesService.prototype);
    ForaAppTypesService.prototype.constructor = ForaAppTypesService;


    ForaAppTypesService.prototype.getDynamicTypeDefinition = function*(name, dynamicResolutionContext) {
        throw new Error("Cannot find type " + name);
    };

    module.exports = ForaAppTypesService;

})();
