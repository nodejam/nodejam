(function() {
    "use strict";

    var recordCommon = require('./record-common'),
        randomizer = require('fora-lib-randomizer'),
        dataUtils = require('fora-data-utils'),
        services = require('fora-lib-services'),
        DbConnector = require('fora-lib-db-connector'),
        Parser = require('fora-request-parser'),
        models = require('./');

    var typesService = services.getTypesService();

    var Record = function(params) {
        dataUtils.extend(this, params);
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        if (this.my_init)
            this.my_init();
    };

    recordCommon.extendRecord(Record);

    var recordStore = new DbConnector(Record);


    var getLimit = function(limit, _default, max) {
        var result = _default;
        if (limit) {
            result = limit;
            if (result > max)
                result = max;
        }
        return result;
    };


    Record.search = function*(criteria, settings) {
        var limit = getLimit(settings.limit, 100, 1000);

        var params = {};
        for (var k in criteria) {
            v = criteria[k];
            params[k] = v;
        }

        return yield* recordStore.find(params, { sort: settings.sort, limit: limit });
    };



    Record.createViaRequest = function*(app, request) {
        var typesService = services.getTypesService();
        var typeDefinition = yield* typesService.getTypeDefinition(Record.typeDefinition.name);

        var parser = new Parser(request, typesService);

        var record = yield* typesService.constructModel({
            type: yield* parser.body('type'),
            version: yield* parser.body('version'),
            createdBy: request.session.user,
            state: yield* parser.body('state'),
            rating: 0,
            savedAt: Date.now(),
            appId: DbConnector.getRowId(app)
        }, typeDefinition);

        var def = yield* record.getTypeDefinition();
        yield* parser.map(record, def, yield* record.getCustomFields(def));
        return yield* record.save();
    };



    Record.prototype.updateViaRequest = function*(request) {
        var def = yield* this.getTypeDefinition();
        yield* parser.map(this, def, yield* this.getCustomFields());
        this.savedAt = Date.now();
        if (yield* parser.body('state') === 'published') this.state = 'published';
        return yield* this.save();
    };



    Record.prototype.addMetaViaRequest = function*(request) {
        var parser = new Parser(request, services.getTypesService());
        var meta = yield* parser.body('meta');
        if (meta) {
            yield* this.addMeta(meta.split(','));
            return yield* this.save();
        } else {
            throw new Error("Meta was not supplied");
        }
    };



    Record.prototype.deleteMetaViaRequest = function*(request) {
        var parser = new Parser(request, services.getTypesService());
        var meta = yield* parser.body('meta');
        if (meta) {
            yield* this.deleteMeta(meta.split(','));
            return yield* this.save();
        } else {
            throw new Error("Meta was not supplied");
        }
    };



    Record.prototype.save = function*() {
        var extensionsService = services.getExtensionsService();
        var model = extensionsService.getModule("record", this.type, this.version, "model");

        var typeParts = this.type.split('/');
        this.recordType = typeParts[1];
        this.version = typeParts[2];
        var versionParts = this.version.split('.');
        this.versionMajor = parseInt(versionParts[0]);
        this.versionMinor = parseInt(versionParts[1]);
        this.versionRevision = parseInt(versionParts[2]);

        //if stub is a reserved name, change it
        var conf = services.getConfiguration();
        if (this.stub) {
            if (conf.reservedNames.indexOf(this.stub) > -1)
                throw new Error("Stub cannot be " + this.stub + ", it is reserved");

            var regex = /[a-z][a-z0-9|-]*/;
            if (!regex.test(this.stub))
                throw new Error("Stub is invalid");
        } else {
            this.stub = this.stub || randomizer.uniqueId(16);
        }

        return yield* recordStore.save(this);
    };



    Record.prototype.addMeta = function*(metaList) {
        metaList.forEach(function(m) {
            if (this.meta.indexOf(m) === -1)
                this.meta.push(m);
        }, this);
    };



    Record.prototype.deleteMeta = function*(metaList) {
        this.meta = this.meta.filter(function(m) {
            return metaList.indexOf(m) === -1;
        });
    };



    Record.prototype.getCreator = function*() {
        var userStore = new DbConnector(models.User);
        return yield* userStore.findById(this.createdBy.id);
    };


    exports.Record = Record;

})();
