(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        conf = require('../../../../../config');

    var Parser = require('fora-request-parser');


    var create = function*() {
        var parser = new Parser(this, services.get('typesService'));
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
                    credential = yield* credential.addBuiltin(username, password);
                    break;
                case 'twitter':
                    var id = yield* parser.body('id');
                    username = yield* parser.body('username');
                    var accessToken = yield* parser.body('accessToken');
                    var accessTokenSecret = yield* parser.body('accessTokenSecret');
                    credential = yield* credential.addTwitter(id, username, accessToken, accessTokenSecret);
                    break;
            }

            var session = yield* credential.createSession();
            this.body = { token: session.token };
        }
    };

    module.exports = { create: create };

})();
