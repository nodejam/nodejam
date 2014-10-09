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


    ForaDbModel.prototype = Object.create(odm.DatabaseModel.prototype);
    ForaDbModel.prototype.constructor = ForaDbModel;

    __extends(ForaDbModel, odm.DatabaseModel);

    var _svc;
    var getServices = function() {
        if (!_svc)
            _svc = services.copy();
        return _svc;
    };


    ForaDbModel.prototype.getRowId = function() {
        var services = getServices();
        return services.db.getRowId(this);
    };


    ForaDbModel.prototype.setRowId = function(id) {
        var services = getServices();
        return services.db.setRowId(this, id);
    };


    ForaDbModel.findById = function*(id) {
        var services = getServices();
        var query = services.db.setRowId({}, id);
        return yield* odm.DatabaseModel.findOne.call(this, query, {}, getServices());
    };


    ForaDbModel.find = function*(query, options) {
        return yield* odm.DatabaseModel.find.call(this, query, options, getServices());
    };


    ForaDbModel.findOne = function*(query, options) {
        return yield* odm.DatabaseModel.findOne.call(this, query, options, getServices());
    };


    ForaDbModel.count = function*(query) {
        return yield* odm.DatabaseModel.count.call(this, query, options, getServices());
    };


    ForaDbModel.destroyAll = function*(query) {
        return yield* odm.DatabaseModel.destroyAll.call(this, query, options, getServices());
    };


    ForaDbModel.prototype.save = function*() {
        return yield* odm.DatabaseModel.prototype.save.call(this, getServices());
    };


    ForaDbModel.prototype.destroy = function*() {
        return yield* odm.DatabaseModel.prototype.destroy.call(this, getServices());
    };


    ForaDbModel.prototype.link = function*(name) {
        return yield* odm.DatabaseModel.prototype.link.call(this,name);
    };

    exports.ForaModel = ForaModel;
    exports.ForaDbModel = ForaDbModel;

})();
