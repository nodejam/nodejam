(function() {
    "use strict";

    var _;
    var services = require('fora-app-services');

    var typesService = services.get('types'),
        conf = services.get('config'),
        db = services.get('db');

    var context = { typesService: typesService, db: db };


    var join = function*() {
        var app = this.app;
        _ = yield* app.join(this.session.user, context);
        this.body = { success: true };
    };


    var auth = require('fora-app-auth-service')(conf, db);
    module.exports = {
        join: auth({ session: 'user' }, join)
    };

})();
