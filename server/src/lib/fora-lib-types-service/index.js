(function() {

    "use strict";

    var _;

    var services = require('fora-lib-services');
    var ForaTypesService = require('ceramic');

    var ForaAppTypesService = function() {
        ForaTypesService.call(this);
        this.extensionsService = services.getExtensionsService();
        this.db = services.getDb();
    };

    ForaAppTypesService.prototype = Object.create(ForaTypesService.prototype);
    ForaAppTypesService.prototype.constructor = ForaAppTypesService;


    ForaAppTypesService.prototype.constructEntity = function*(obj, entitySchema, options, skipInitialize) {
        var effectiveTypeDef = yield* ForaTypesService.prototype.getEffectiveEntitySchema.call(this, obj, entitySchema);

        var result = yield* ForaTypesService.prototype.constructEntity.call(this, obj, effectiveTypeDef, options);

        result.getEntitySchema = function*() {
            return effectiveTypeDef;
        };

        if (!skipInitialize) {
            var initialize;
            if (effectiveTypeDef.initialize)
                initialize = effectiveTypeDef.initialize;
            else if (effectiveTypeDef.baseEntitySchema && effectiveTypeDef.baseEntitySchema.initialize)
                initialize = effectiveTypeDef.baseEntitySchema.initialize;
            if (initialize)
                initialize.call(effectiveTypeDef, result, obj, effectiveTypeDef, this);
        }

        return result;
    };


    ForaAppTypesService.prototype.updateEntity = function*(target, obj, entitySchema, options) {
        yield* ForaTypesService.prototype.updateEntity.call(this, target, obj, entitySchema, options);
        var rowId = this.db.getRowId(obj);
        if (rowId)
            this.db.setRowId(target, rowId);
    };


    ForaAppTypesService.prototype.isModel = function(value) {
        //In the case of virtual types (App and Record), we'll have value.getEntitySchema.
        //Static types will have value.constructor.entitySchema.
        return value && (value.getEntitySchema || (value.constructor && value.constructor.entitySchema));
    };


    ForaAppTypesService.prototype.getDynamicEntitySchema = function*(name, dynamicResolutionContext) {
        throw new Error("Cannot find type " + name);
    };

    module.exports = ForaAppTypesService;

})();
