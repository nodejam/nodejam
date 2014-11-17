(function() {

    "use strict";

    var _;

    var services = require('fora-app-services');
    var ForaTypesService = require('fora-types-service');

    var ForaAppTypesService = function() {
        ForaTypesService.call(this);
        this.extensionsService = services.get('extensionsService');
        this.db = services.get('db');
    };

    ForaAppTypesService.prototype = Object.create(ForaTypesService.prototype);
    ForaAppTypesService.prototype.constructor = ForaAppTypesService;


    ForaAppTypesService.prototype.constructModel = function*(obj, typeDefinition, skipInitialize) {
        var effectiveTypeDef = yield* ForaTypesService.prototype.getEffectiveTypeDefinition.call(this, obj, typeDefinition);

        var result = yield* ForaTypesService.prototype.constructModel.call(this, obj, effectiveTypeDef);

        result.getTypeDefinition = function*() {
            return effectiveTypeDef;
        };

        if (!skipInitialize) {
            var initialize;
            if (effectiveTypeDef.initialize)
                initialize = effectiveTypeDef.initialize;
            else if (effectiveTypeDef.baseTypeDefinition && effectiveTypeDef.baseTypeDefinition.initialize)
                initialize = effectiveTypeDef.baseTypeDefinition.initialize;
            if (initialize)
                initialize.call(effectiveTypeDef, result, obj, effectiveTypeDef, this);
        }

        return result;
    };


    ForaAppTypesService.prototype.updateModel = function*(target, obj, typeDefinition) {
        _ = yield* ForaTypesService.prototype.updateModel.call(this, target, obj, typeDefinition);
        var rowId = this.db.getRowId(obj);
        if (rowId)
            this.db.setRowId(target, rowId);
    };


    ForaAppTypesService.prototype.isModel = function(value) {
        return value && value.constructor && value.constructor.typeDefinition;
    };


    ForaAppTypesService.prototype.getDynamicTypeDefinition = function*(name, dynamicResolutionContext) {
        throw new Error("Cannot find type " + name);
    };

    module.exports = ForaAppTypesService;

})();
