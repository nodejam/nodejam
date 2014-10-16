(function() {
    "use strict";

    var _;

    var Router = require('fora-router');


    var TrustedSandbox = function(extension, moduleName) {
        this.extension = extension;
        this.moduleName = moduleName;
    };


    TrustedSandbox.prototype.executeRequest = function*(requestContext) {
        var extensionModule = this.extension[this.moduleName];
        if (!extensionModule.__router) {
            extensionModule.__router = new Router();
            extensionModule.routes.forEach(function(route) {
                extensionModule.__router[route.method](route.url, route.handler);
            });
        }
        var routeFunc = extensionModule.__router.route();
        return yield* routeFunc.call(requestContext, null);
    };


    module.exports = TrustedSandbox;

})();
