(function() {
    "use strict";

    var _;


    var TrustedSandbox = function(extension, app, extensionModule) {
        this.extension = extension;
        this.app = app;
        this.extensionModule = extensionModule;
    };


    TrustedSandbox.prototype.executeRequest = function*(requestContext) {
        var router = yield* this.extension[this.extensionModule].getRouter();
        var routeFunc = router.route();
        return yield* routeFunc.call(requestContext);
    };


    module.exports = TrustedSandbox;

})();
