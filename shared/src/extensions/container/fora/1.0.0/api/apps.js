(function() {
    "use strict";

    var models = require('fora-app-models');
    var services = require('fora-services');

    module.exports = function(params) {

        ,
            db = params.db,
            mapper = params.mapper,
            loader = params.loader;

        var create = function*() {
            var conf = services.get('conf');
            var context = { user: this.session.user };

            var stub = yield* this.parser.body('name').toLowerCase().trim();
            if (conf.reservedNames.indexOf(stub) > -1)
                stub = stub + "-app";
            stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'');

            var app = yield* models.App.get({
                network: this.network.stub,
                $or: [{ stub: stub }, { name: yield* this.parser.body('name') }],
                context: context,
                db: db
            });

            if (app) {
                throw new Error("App exists");
            } else {
                app = yield* models.App.create({
                    type: yield* this.parser.body('type'),
                    name: yield* this.parser.body('name'),
                    access: yield* this.parser.body('access'),
                    network: this.network.stub,
                    stub: stub,
                    createdById: this.session.user.id,
                    createdBy: this.session.user,
                });

                yield* this.parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
                yield* this.parser.map(app, yield* mapper.getMappableFields(yield* app.getTypeDefinition()));
                app = yield* app.save(context, db);
                yield* app.addRole(this.session.user, 'admin');
                this.body = app;
            }
        };



        var edit = function*(app) {
            var context = { user: this.session.user };
            var app = yield* models.App.get({ stub: app, network: this.network.stub }, { user: this.session.user }, db);

            if (this.session.user.username === app.createdBy.username || this.session.admin) {
                yield* this.parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
                yield* this.parser.map(app, yield* mapper.getMappableFields(yield* app.getTypeDefinition()));
                app = yield* app.save();
                this.body = app;
            } else {
                throw new Error("Access denied");
            }
        };



        var join = function*(app) {
            app = yield* models.App.get({ stub: app, network: this.network.stub }, { user: this.session.user }, db);
            yield* app.join(this.session.user);
            this.body = { success: true };
        };

        var auth = services.get('auth');

        return {
            create: auth.handler({ session: 'user' }, create),
            edit: auth.handler({ session: 'user' }, edit),
            join: auth.handler({ session: 'user' }, join)
        };
    };
})();
