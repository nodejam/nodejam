(function() {
    "use strict";

    var create = function*() {
        if (yield* this.parser.body('secret') === conf.auth.adminkeys.default) {
            var type = yield* this.parser.body('type');

            var credential = new models.Credential({
                email: yield* this.parser.body('email'),
                preferences: { canEmail: true }
            });

            var username;
            switch(type) {
                case 'builtin':
                    username = yield* this.parser.body('username');
                    var password = yield* this.parser.body('password');
                    credential = yield* credential.addBuiltin(username, password, {}, db);
                    break;
                case 'twitter':
                    var id = yield* this.parser.body('id');
                    username = yield* this.parser.body('username');
                    var accessToken = yield* this.parser.body('accessToken');
                    var accessTokenSecret = yield* this.parser.body('accessTokenSecret');
                    credential = yield* credential.addTwitter(id, username, accessToken, accessTokenSecret, {}, db);
                    break;
            }

            var session = yield* credential.createSession({}, db);
            this.body = { token: session.token };
        }
    };

    module.exports = { create: auth.handler({ session: 'user' }, create) };

})();
