(function() {
    "use strict";

    var _;
    var models = require('fora-app-models'),
        services = require('fora-app-services');

    var typesService = services.get('types'),
        conf = services.get('config'),
        db = services.get('db');

    var Parser = require('fora-request-parser')(typesService);

    var context = { typesService: typesService, db: db };


    var create = function*(appStub) {
        var parser = new Parser(this);
        var app = this.app;

        var record = yield* models.Record.create({
            type: yield* parser.body('type'),
            createdById: this.session.user.id,
            createdBy: this.session.user,
            state: yield* parser.body('state'),
            rating: 0,
            savedAt: Date.now()
        });

        _ = yield* parser.map(record, yield* mapper.getMappableFields(yield* record.getTypeDefinition()));
        record = yield* app.addRecord(record);
        this.body = record;
    };


    var edit = function*(appStub, recordStub) {
        var parser = new Parser(this);
        var app = this.app;
        var record = yield* models.Record.get({ stub: recordStub, appId: app._id.toString() }, { user: this.session.user }, db);

        if (record) {
            if (record.createdBy.username === this.session.user.username) {
                record.savedAt = Date.now();
                _ = yield* parser.map(record, yield* mapper.getMappableFields(yield* record.getTypeDefinition()));
                if (yield* parser.body('state') === 'published') {
                    record.state = 'published';
                }
                record = yield* record.save();
                this.body = record;
            } else {
                throw new Error('Access denied');
            }
        } else {
            throw new Error('Access denied', 403);
        }
    };


    var remove = function*(appStub, recordStub) {
        var app = yield* models.App.get({ stub: appStub, network: this.network.stub }, { user: this.session.user }, db);
        var record = yield* models.Record.get({ stub: recordStub, appId: app._id.toString() }, { user: this.session.user }, db);

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


    var admin_update = function*(appStub, recordStub) {
        var app = yield* models.App.get({ stub: appStub, network: this.network.stub }, { user: this.session.user }, db);
        var record = yield* models.Record.get({ stub: recordStub, appId: app._id.toString() }, { user: this.session.user }, db);

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


    var auth = require('fora-app-auth-service')(conf, db);
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit),
        remove: auth({ session: 'user' }, remove),
        admin_update: auth({ session: 'admin' }, admin_update)
    };


})();
