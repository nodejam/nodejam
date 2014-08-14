(function() {
    "use strict";

    var _;

    var odm = require('fora-models');

    var ForaTypesServiceBase = function() {
        odm.TypesService.apply(this, arguments);
    };

    ForaTypesServiceBase.prototype = Object.create(odm.TypesService.prototype);
    ForaTypesServiceBase.prototype.constructor = ForaTypesServiceBase;

    var initted = false;


    ForaTypesServiceBase.prototype.init = function*(ctors, virtualTypeDefinitions) {
        if (!initted) {
            yield* this.buildTypeCache(ctors, virtualTypeDefinitions);
        } else {
            throw new Error("init() was already called");
        }
    };


    ForaTypesServiceBase.prototype.resolveDerivedTypeDefinition = function*(name) {
        //TODO: make sure we dont allow special characters in name, like '..'
        console.log("Missing " + JSON.stringify(name));
    };

    module.exports = ForaTypesServiceBase;

})();
