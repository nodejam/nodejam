(function() {

    var database = require('ceramic-db'),
        services = require('fora-lib-services');

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
        return yield* database.findOne(typeDefinition, query, {}, services.typesService, services.db);
    };


    Connector.prototype.find = function*(query, options) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.find(typeDefinition, query, options, services.typesService, services.db);
    };


    Connector.prototype.findOne = function*(query, options) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.findOne(typeDefinition, query, options, services.typesService, services.db);
    };


    Connector.prototype.count = function*(query) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.count(typeDefinition, query, services.typesService, services.db);
    };


    Connector.prototype.destroyAll = function*(query) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinition();
        return yield* database.destroyAll(typeDefinition, query, services.typesService, services.db);
    };


    Connector.prototype.save = function*(record) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.save(record, typeDefinition, services.typesService, services.db);
    };


    Connector.prototype.destroy = function*(record) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.destroy(record, typeDefinition, services.typesService, services.db);
    };


    Connector.prototype.link = function*(record, name) {
        var services = getServices();
        var typeDefinition = yield* this.getTypeDefinitionFromRecord(record);
        return yield* database.link(record, typeDefinition, name, services.typesService, services.db);
    };

    module.exports = Connector;

})();
