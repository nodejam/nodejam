(function() {
    "use strict";

    var _;

    var create = function*() {
        var app = this.app;
        
        var record = yield* app.createRecord({
            type: yield* this.parser.body('type'),
            version: yield* this.parser.body('version'),
            createdBy: this.session.user,
            state: yield* this.parser.body('state'),
            rating: 0,
            savedAt: Date.now()
        });

        _ = yield* this.parser.map(record, yield* record.getMappableFields());

        //record.app isnt in record, it's in article. FIXME
        record.app = yield* this.app.summarize();
        record = yield* this.app.addRecord(record);

        //Add to cache.
        if (!app.cache.records)
            app.cache.records = [];

        if (app.cache.records.length > 10)
            app.cache.records.slice(app.cache.records.length - 10);

        app.stats.lastRecord = Date.now();

        app.cache.records.push(
            {
                createdBy: record.createdBy,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt
            }
        );

        _ = yield* app.save();

        this.body = record;
    };



    var edit = function*(stub) {
        var record = yield* this.app.findRecord({ stub: stub });

        if (record) {
            if (record.createdBy.username === this.session.user.username) {
                record.savedAt = Date.now();
                _ = yield* this.parser.map(record, yield* record.getMappableFields());
                if (yield* this.parser.body('state') === 'published') record.state = 'published';
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
        var record = yield* this.app.getRecord(stub);

        if (record) {
            var meta = yield* this.parser.body('meta');
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
