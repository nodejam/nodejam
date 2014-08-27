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
            _ = yield* this.buildTypeCache(ctors, virtualTypeDefinitions);
        } else {
            throw new Error("init() was already called");
        }
    };


    module.exports = ForaTypesServiceBase;

})();
