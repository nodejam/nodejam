(function() {
    "use strict";

    var _;

    var SDK1 = require('../../sdk/1/trusted');

    var TrustedSandbox = function(extension, extensionModule) {
        this.extension = extension;
        this.extensionModule = extensionModule;
    };


    TrustedSandbox.prototype.executeRequest = function*(requestContext, routingContext) {
        if (routingContext.app.sdkRevision === 1)
            requestContext.sdk = SDK1(routingContext.app);
        else
            throw new Error("SDK version " + routingContext.app.sdkRevision + " is not available");

        var router = yield* this.extension[this.extensionModule].getRouter();
        var routeFunc = router.route();
        return yield* routeFunc.call(requestContext);
    };


    module.exports = TrustedSandbox;

})();
