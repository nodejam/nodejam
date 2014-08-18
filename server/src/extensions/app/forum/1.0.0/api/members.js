(function() {
    "use strict";

    var join = function*() {
        var app = this.app;
        _ = yield* app.join(this.session.user);
        this.body = { success: true };
    };


    module.exports = {
        join: join
    };

})();
