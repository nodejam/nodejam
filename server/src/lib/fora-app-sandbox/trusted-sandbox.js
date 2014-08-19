(function() {
    "use strict";

    var _;


    var TrustedSandbox = function(appExtension, app) {
        this.appExtension = appExtension;
        this.app = app;
    };


    TrustedSandbox.prototype.executeRequest = function*(context, app) {
        var router = yield* this.appExtension.api.getRouter();
        context.app = this.app;
        _ = yield* router.route().call(context);
    };


    module.exports = TrustedSandbox;

})();
