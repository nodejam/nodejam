(function() {
    "use strict";

    var _;


    var TrustedSandbox = function(extension, extensionModuleName) {
        this.extension = extension;
        this.extensionModuleName = extensionModuleName;
    };


    TrustedSandbox.prototype.executeRequest = function*(requestContext) {
        var router = yield* this.extension[this.extensionModuleName].getRouter();
        var routeFunc = router.route();
        return yield* routeFunc.call(requestContext, null);
    };


    module.exports = TrustedSandbox;

})();
