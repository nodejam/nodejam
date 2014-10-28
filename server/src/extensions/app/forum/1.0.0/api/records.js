(function() {
    "use strict";

    var _;

    var services = require("fora-app-services"),
        Parser = require('fora-request-parser');


    var create = function*() {
        var typesService = services.get("typesService"),
            extensionsService = services.get("extensionsService");

        var parser = new Parser(this, typesService);

        var record = yield* this.app.createRecord({
            type: yield* parser.body('type'),
            version: yield* parser.body('version'),
            createdBy: this.session.user,
            state: yield* parser.body('state'),
            rating: 0,
            savedAt: Date.now()
        });

        _ = yield* parser.map(record, yield* record.getMappableFields());

        record.app = yield* this.app.summarize();
        record = yield* this.app.addRecord(record);

        //Update the last updated time
        this.app.stats.lastRecord = Date.now();

        //Add to cache.
        if (!this.app.cache.records)
            this.app.cache.records = [];

        var cacheItem;
        var modelModule = yield* extensionsService.getModuleByFullType(record.type, "model");

        if (modelModule) {
            var model = modelModule();
            if (model.getCacheItem)
                cacheItem = yield* model.getCacheItem.call(this);
        }
        if (!cacheItem && record.title) {
            cacheItem = {
                title: record.title,
                createdBy: record.createdBy,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt
            };
        }

        if (cacheItem) {
            this.app.cache.records.push(cacheItem);

            if (this.app.cache.records.length > 10)
                this.app.cache.records.slice(this.app.cache.records.length - 10);
        }

        _ = yield* this.app.save();

        this.body = record;
    };



    var edit = function*(stub) {
        var typesService = services.get("typesService"),
            extensionsService = services.get("extensionsService");

        var parser = new Parser(this, typesService);
        var record = yield* this.app.findRecord({ stub: stub });

        if (record) {
            if (record.createdBy.username === this.session.user.username) {
                record.savedAt = Date.now();
                _ = yield* parser.map(record, yield* record.getMappableFields());
                if (yield* parser.body('state') === 'published') record.state = 'published';
                this.body = yield* record.save();
            } else {
                throw new Error('Access denied');
            }
        } else {
            throw new Error('Access denied', 403);
        }
    };



    var remove = function*(stub) {
        var record = yield* this.app.getRecord({ stub: stub });

        if (record) {
            if (record.createdBy.username === this.session.user.username) {
                record = yield* record.destroy();
                this.body = record;
            } else {
                throw new Error('Access denied');
            }
        } else {
            throw new Error('Access denied');
        }
    };



    var admin_update = function*(stub) {
        var parser = new Parser(this, services.get('typesService'));
        var record = yield* this.app.getRecord(stub);

        if (record) {
            var meta = yield* parser.body('meta');
            if (meta) {
                record = yield* record.addMetaList(meta.split(','));
                this.body = record;
            } else {
                throw new Error("No meta was supplied");
            }
        } else {
            throw new Error('Missing record');
        }
    };



    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit),
        remove: auth({ session: 'user' }, remove),
        admin_update: auth({ session: 'admin' }, admin_update)
    };


})();
