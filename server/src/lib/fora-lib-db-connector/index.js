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


    Connector.prototype.getEntitySchema = function*() {
        var typesService = services.getTypesService();
        if (!this.ctor.__entitySchema) {
            this.ctor.__entitySchema = yield typesService.getEntitySchema(this.ctor.entitySchema.schema.id);
        }
        return this.ctor.__entitySchema;
    };


    Connector.prototype.getEntitySchemaFromRecord = function*(record) {
        var typesService = services.getTypesService();
        if (record) {
            if (record.getEntitySchema) {
                return yield record.getEntitySchema();
            } else {
                var typeDef = yield this.getEntitySchema();
                return yield typesService.getEffectiveEntitySchema(record, typeDef);
            }
        }
        return yield this.getEntitySchema();
    };


    Connector.prototype.findById = function*(id) {
        var services = getServices();
        var query = services.db.setRowId({}, id);
        var entitySchema = yield this.getEntitySchema();
        return yield database.findOne(entitySchema, query, {}, services.typesService, services.db);
    };


    Connector.prototype.find = function*(query, options) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchema();
        return yield database.find(entitySchema, query, options, services.typesService, services.db);
    };


    Connector.prototype.findOne = function*(query, options) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchema();
        return yield database.findOne(entitySchema, query, options, services.typesService, services.db);
    };


    Connector.prototype.count = function*(query) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchema();
        return yield database.count(entitySchema, query, services.typesService, services.db);
    };


    Connector.prototype.destroyAll = function*(query) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchema();
        return yield database.destroyAll(entitySchema, query, services.typesService, services.db);
    };


    Connector.prototype.save = function*(record) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchemaFromRecord(record);
        return yield database.save(record, entitySchema, services.typesService, services.db);
    };


    Connector.prototype.destroy = function*(record) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchemaFromRecord(record);
        return yield database.destroy(record, entitySchema, services.typesService, services.db);
    };


    Connector.prototype.link = function*(record, name) {
        var services = getServices();
        var entitySchema = yield this.getEntitySchemaFromRecord(record);
        return yield database.link(record, entitySchema, name, services.typesService, services.db);
    };

    module.exports = Connector;

})();
