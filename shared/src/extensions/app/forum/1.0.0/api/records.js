(function() {
    "use strict";

    var _;

    module.exports = function(params) {
        var typeService = params.typeService,
            models = params.models,
            db = params.db,
            conf = params.conf,
            auth = params.auth,
            mapper = params.mapper,
            loader = params.loader;


        var create = auth.handler({ session: 'user' }, function*(appStub) {
            var app = yield* models.App.get({ stub: appStub, network: this.network.stub }, { user: this.session.user }, db);

            var record = yield* models.Record.create({
                type: yield* this.parser.body('type'),
                createdById: this.session.user.id,
                createdBy: this.session.user,
                state: yield* this.parser.body('state'),
                rating: 0,
                savedAt: Date.now()
            });

            _ = yield* this.parser.map(record, yield* mapper.getMappableFields(yield* record.getTypeDefinition()));
            record = yield* app.addRecord(record);
            this.body = record;
        });


        var edit = function*(appStub, recordStub) {
            var app = yield* models.App.get({ stub: appStub, network: this.network.stub }, { user: this.session.user }, db);
            var record = yield* models.Record.get({ stub: recordStub, appId: app._id.toString() }, { user: this.session.user }, db);

            if (record) {
                if (record.createdBy.username === this.session.user.username) {
                    record.savedAt = Date.now();
                    _ = yield* this.parser.map(record, yield* mapper.getMappableFields(yield* record.getTypeDefinition()));
                    if (yield* this.parser.body('state') === 'published') {
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
                var meta = yield* this.parser.body('meta');
                if (meta) {
                    var record = yield* record.addMetaList(meta.split(','));
                    this.body = record;
                } else {
                    throw new Error("No meta was supplied")
                }
            } else {
                throw new Error('Missing record');
            }
        };

        return {
            create: auth.handler({ session: 'user' }, create),
            edit: auth.handler({ session: 'user' }, edit),
            remove: auth.handler({ session: 'user' }, remove),
            admin_update: auth.handler({ session: 'admin' }, admin_update)
        };
})();
