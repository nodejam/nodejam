(function() {
    "use strict";

    var _;


    var UntrustedSandbox = function(appExtension, app) {
        this.appExtension = appExtension;
        this.app = app;
    };


    UntrustedSandbox.prototype.executeRequest = function*(context, app) {
        var router = yield* this.appExtension.api.getRouter();
        context.app = this.app;
        _ = yield* router.route().call(context);
    };


    module.exports = UntrustedSandbox;

})();
