(function() {
    "use strict";

    var _;

    var create = function*() {
        var record = yield* this.application.createRecord({
            type: yield* this.parser.body('type'),
            version: yield* this.parser.body('version'),
            createdBy: this.session.user,
            state: yield* this.parser.body('state'),
            rating: 0,
            savedAt: Date.now()
        });

        _ = yield* this.parser.map(record, yield* record.getMappableFields());

        this.body = yield* this.application.addRecord(record);
    };



    var edit = function*(stub) {
        var record = yield* this.application.findRecord({ stub: stub });

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
        var record = yield* this.application.getRecord({ stub: stub });

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
        var record = yield* this.application.getRecord(stub);

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
