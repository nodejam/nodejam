(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-services'),
        typeHelpers = require('fora-type-helpers');

    var conf = services.get('configuration'),
        Parser = services.get('parserService'),
        typesService = services.get('typesService'),
        db = services.get('db');

    var context = { typesService: typesService, db: db };


    var create = function*() {
        var parser = new Parser(this);

        var stub = yield* parser.body('name').toLowerCase().trim();
        if (conf.reservedNames.indexOf(stub) > -1)
            stub = stub + "-app";
        stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'');

        var app = yield* models.App.get({
                network: this.network.stub,
                $or: [{ stub: stub }, { name: yield* parser.body('name') }]
            }, typeHelpers.extend({ user: this.session.user }, context)
        );

        if (app) {
            throw new Error("App exists");
        } else {
            app = yield* models.App.create({
                type: yield* parser.body('type'),
                name: yield* parser.body('name'),
                access: yield* parser.body('access'),
                network: this.network.stub,
                stub: stub,
                createdById: this.session.user.id,
                createdBy: this.session.user,
            });

            _ = yield* parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            _ = yield* parser.map(app, yield* mapper.getMappableFields(yield* app.getTypeDefinition()));
            app = yield* app.save(typeHelpers.extend(context));
            _ = yield* app.addRole(this.session.user, 'admin');
            this.body = app;
        }
    };



    var edit = function*(app) {
        var parser = new Parser(this);
        var context = { user: this.session.user };
        app = yield* models.App.get({ stub: app, network: this.network.stub }, context);

        if (this.session.user.username === app.createdBy.username || this.session.admin) {
            _ = yield* parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            _ = yield* parser.map(app, yield* mapper.getMappableFields(yield* app.getTypeDefinition()));
            app = yield* app.save(context);
            this.body = app;
        } else {
            throw new Error("Access denied");
        }
    };



    var join = function*(app) {
        app = yield* models.App.get({ stub: app, network: this.network.stub }, context);
        _ = yield* app.join(this.session.user);
        this.body = { success: true };
    };



    var auth = services.get('authService');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit),
        join: auth({ session: 'user' }, join)
    };



})();
