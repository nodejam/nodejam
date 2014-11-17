(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        dataUtils = require('fora-data-utils'),
        Parser = require('fora-request-parser'),
        DbConnector = require('fora-app-db-connector');

    var create = function*() {
        var appStore = new DbConnector(models.App);

        var typesService = services.get('typesService');
        var conf = services.get("configuration");
        var parser = new Parser(this, typesService);

        var stub = (yield* parser.body('name')).toLowerCase().trim();
        if (conf.reservedNames.indexOf(stub) > -1)
            stub = stub + "-app";
        stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'');

        var app = yield* appStore.findOne({ $or: [{ stub: stub }, { name: yield* parser.body('name') }] });

        if (!app) {
            var type = yield* parser.body('type');
            var typeDefinition = yield* typesService.getTypeDefinition(type);
            var params = {
                type: type,
                name: yield* parser.body('name'),
                access: yield* parser.body('access'),
                stub: stub,
                createdBy: this.session.user,
            };
            app = yield* typesService.constructModel(params, typeDefinition);

            _ = yield* parser.map(
                app,
                (yield* appStore.getTypeDefinition()),
                ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']
            );

            app = yield* app.save();

            _ = yield* app.addRole(this.session.user, 'admin');

            this.body = app;

        } else {
            throw new Error("App exists");
        }
    };



    var edit = function*(app) {
        var appStore = new DbConnector(models.App);
        var parser = new Parser(this, services.get('typesService'));

        app = yield* appStore.findOne({ stub: app });

        if (this.session.user.username === app.createdBy.username || this.session.admin) {
            _ = yield* parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            app = yield* app.save();
            this.body = app;
        } else {
            throw new Error("Access denied");
        }
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit)
    };



})();
