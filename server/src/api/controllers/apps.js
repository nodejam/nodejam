(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        typeHelpers = require('fora-app-type-helpers'),
        conf = require('../../config');

    var Parser = require('fora-request-parser');


    var create = function*() {
        var parser = new Parser(this, services.get('typesService'));

        var stub = (yield* parser.body('name')).toLowerCase().trim();
        if (conf.reservedNames.indexOf(stub) > -1)
            stub = stub + "-app";
        stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'');

        var app = yield* models.App.findOne({
                $or: [{ stub: stub }, { name: yield* parser.body('name') }]
            }, typeHelpers.extend({ user: this.session.user }, services.copy())
        );

        if (!app) {
            app = new models.App({
                type: yield* parser.body('type'),
                version: yield* parser.body('version'),
                name: yield* parser.body('name'),
                access: yield* parser.body('access'),
                stub: stub,
                createdBy: this.session.user,
            });

            _ = yield* parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            app = yield* app.save();
            _ = yield* app.addRole(this.session.user, 'admin');

            this.body = app;

        } else {
            throw new Error("App exists");
        }
    };



    var edit = function*(app) {
        var parser = new Parser(this, services.get('typesService'));

        app = yield* models.App.findOne({ stub: app }, services.copy());

        if (this.session.user.username === app.createdBy.username || this.session.admin) {
            _ = yield* parser.map(app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            app = yield* app.save();
            this.body = app;
        } else {
            throw new Error("Access denied");
        }
    };


    var auth = require('fora-app-auth-service')(conf, services.get('typesService'), services.get('db'));
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit)
    };



})();
