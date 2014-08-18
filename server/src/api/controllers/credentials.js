(function() {
    "use strict";

    var _;

    var models = require('../../models'),
        services = require('../../common/fora-services'),
        typeHelpers = require('fora-type-helpers'),
        conf = require('../../config');

    var typesService = services.get('types'),
        db = services.get('db');

    var Parser = require('fora-request-parser')(typesService);
    var context = { typesService: typesService, db: db };


    var create = function*() {
        var parser = new Parser(this);
        if ((yield* parser.body('secret')) === conf.services.auth.adminkeys.default) {
            var type = yield* parser.body('type');

            var credential = new models.Credential({
                email: yield* parser.body('email'),
                preferences: { canEmail: true }
            });

            var username;
            switch(type) {
                case 'builtin':
                    username = yield* parser.body('username');
                    var password = yield* parser.body('password');
                    credential = yield* credential.addBuiltin(username, password, context);
                    break;
                case 'twitter':
                    var id = yield* parser.body('id');
                    username = yield* parser.body('username');
                    var accessToken = yield* parser.body('accessToken');
                    var accessTokenSecret = yield* parser.body('accessTokenSecret');
                    credential = yield* credential.addTwitter(id, username, accessToken, accessTokenSecret, context);
                    break;
            }

            var session = yield* credential.createSession(context);
            this.body = { token: session.token };
        }
    };

    module.exports = { create: create };

})();
