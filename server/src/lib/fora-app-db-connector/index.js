(function() {

    var database = require('fora-db');
    var services = require('fora-app-services');

    var _svc;
    var getServices = function() {
        if (!_svc)
            _svc = services.copy();
        return _svc;
    };


    var Connector = function(ctor) {
        this.ctor = ctor;
    };


    Connector.getRowId = function(record) {
        var services = getServices();
        return services.db.getRowId(record);
    };


    Connector.setRowId = function(record, id) {
        var services = getServices();
        return services.db.setRowId(record, id);
    };


    Connector.prototype.findById = function*(id) {
        var services = getServices();
        var query = services.db.setRowId({}, id);
        return yield* database.findOne(this.ctor, query, {}, getServices());
    };


    Connector.prototype.find = function*(query, options) {
        return yield* database.find(this.ctor, query, options, getServices());
    };


    Connector.prototype.findOne = function*(query, options) {
        return yield* database.findOne(this.ctor, query, options, getServices());
    };


    Connector.prototype.count = function*(query) {
        return yield* database.count(this.ctor, query, getServices());
    };


    Connector.prototype.destroyAll = function*(query) {
        return yield* database.destroyAll(this.ctor, query, getServices());
    };


    Connector.prototype.save = function*(record) {
        return yield* database.save(record, this.ctor, getServices());
    };


    Connector.prototype.destroy = function*(record) {
        return yield* database.destroy(record, this.ctor, getServices());
    };


    Connector.prototype.link = function*(record, name) {
        return yield* database.link(record, this.ctor, name, getServices());
    };

    module.exports = Connector;

})();
