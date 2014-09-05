(function() {
    "use strict";

    var _;

    var join = function*() {
        _ = yield* this.application.join(this.session.user);
        this.body = { success: true };
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        join: auth({ session: 'user' }, join)
    };

})();
