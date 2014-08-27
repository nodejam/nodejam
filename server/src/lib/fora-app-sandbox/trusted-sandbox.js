(function() {
    "use strict";

    var _;


    var TrustedSandbox = function(appExtension, app) {
        this.appExtension = appExtension;
        this.app = app;
    };


    TrustedSandbox.prototype.executeRequest = function*(requestContext) {
        var router = yield* this.appExtension.api.getRouter();
        var routeFunc = router.route();
        return yield* routeFunc.call(requestContext);
    };


    module.exports = TrustedSandbox;

})();
