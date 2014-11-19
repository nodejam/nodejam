(function() {

    var database = require('fora-db'),
        services = require('fora-app-services');

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


    Connector.prototype.getTypeDefinition = function*() {
        var typesService = services.getTypesService();
        if (!this.ctor.__typeDefinition) {
            this.ctor.__typeDefinition = yield* typesService.getTypeDefinition(this.ctor.typeDefinition.name);
        }
        return this.ctor.__typeDefinition;
    };


    Connector.prototype.getTypeDefinitionFromRecord = function*(record) {
        var typesService = services.getTypesService();
        if (record) {
            if (record.getTypeDefinition) {
                return yield* record.getTypeDefinition();
            } else {
                var typeDef = yield* this.getTypeDefinition();
                return yield* typesService.getEffectiveTypeDefinition(record, typeDef);
            }
        }
        return yield* this.getTypeDefinition();
    };


    Connector.prototype.findById = function*(id) {
        var services = getServices();
        var query = services.db.setRowId({}, id);
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.findOne(typeDefinition, query, {}, getServices());
    };


    Connector.prototype.find = function*(query, options) {
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.find(typeDefinition, query, options, getServices());
    };


    Connector.prototype.findOne = function*(query, options) {
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.findOne(typeDefinition, query, options, getServices());
    };


    Connector.prototype.count = function*(query) {
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.count(typeDefinition, query, getServices());
    };


    Connector.prototype.destroyAll = function*(query) {
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.destroyAll(typeDefinition, query, getServices());
    };


    Connector.prototype.save = function*(record) {
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.save(record, typeDefinition, getServices());
    };


    Connector.prototype.destroy = function*(record) {
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.destroy(record, typeDefinition, getServices());
    };


    Connector.prototype.link = function*(record, name) {
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.link(record, typeDefinition, name, getServices());
    };

    module.exports = Connector;

})();
