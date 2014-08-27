(function() {

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var odm = require('fora-models');
    var services = require('fora-app-services');

    /* ForaModel */

    var ForaModel = function(params) {
        odm.BaseModel.call(this, params);
    };

    ForaModel.prototype = Object.create(odm.BaseModel.prototype);
    ForaModel.prototype.constructor = ForaModel;

    __extends(ForaModel, odm.BaseModel);


    /* ForaDbModel */

    var ForaDbModel = function(params) {
        odm.DatabaseModel.call(this, params);
    };

    ForaDbModel.create = function*(params) {
        var obj;
        var typesService = services.get('typesService');
        var typeDef = yield* this.getTypeDefinition(typesService);
        if (typeDef.discriminator) {
            var actualTypeDef = yield* typeDef.discriminator(params, typesService);
            obj = new actualTypeDef.ctor(params);
            obj.getTypeDefinition = function*() {
                return actualTypeDef;
            };
        } else {
            obj = new typeDef.ctor(params);
        }
        return obj;
    };

    ForaDbModel.prototype = Object.create(odm.DatabaseModel.prototype);
    ForaDbModel.prototype.constructor = ForaDbModel;

    __extends(ForaDbModel, odm.DatabaseModel);

    ForaDbModel.prototype.save = function*() {
        return yield* odm.DatabaseModel.prototype.save.call(this, services.copy());
    };

    exports.ForaModel = ForaModel;
    exports.ForaDbModel = ForaDbModel;

})();
