(function() {
    "use strict";

    var ForaTypesServiceBase = require('./fora-types-service-base');

    var ForaTypesService = function(extensionsService) {
        this.extensionsService = extensionsService;
        ForaTypesServiceBase.apply(this);
    };

    ForaTypesService.prototype = Object.create(ForaTypesServiceBase.prototype);
    ForaTypesService.prototype.constructor = ForaTypesService;


    ForaTypesService.prototype.getVirtualTypeDefinitions = function*() {
        return [];
    };


    module.exports = ForaTypesService;

})();
