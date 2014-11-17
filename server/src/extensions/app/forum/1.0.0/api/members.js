(function() {
    "use strict";

    var _;

    var join = function*() {
        this.body = yield* this.app.join(this.session.user);
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        join: auth({ session: 'user' }, join)
    };

})();
