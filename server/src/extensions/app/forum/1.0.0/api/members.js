(function() {
    "use strict";

    var models = require('fora-app-models');
    

    var join = function*(app) {
        app = yield* models.App.findOne({ stub: app }, context);
        _ = yield* app.join(this.session.user);
        this.body = { success: true };
    };


    var auth = require('../../common/auth-service')(conf, db);
    module.exports = {
        join: auth({ session: 'user' }, join)
    };

})();
