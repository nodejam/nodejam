(function() {
    "use strict";

    var _;

    var Router = require('fora-lib-router');

    var TrustedSandbox = function(extension, moduleName, extensionsService) {
        this.extension = extension;
        this.moduleName = moduleName;
        this.extensionsService = extensionsService;
    };

    TrustedSandbox.prototype.executeRequest = function*(requestContext) {
        var requestHandler = this.extension[this.moduleName];

        if (!requestHandler.__router) {
            requestHandler.__router = new Router();
            requestHandler.routes.forEach(function(route) {
                requestHandler.__router[route.method](route.url, route.handler);
            });
        }

        var routeFunc = requestHandler.__router.route();

        return yield* routeFunc.call(requestContext, null);
    };


    module.exports = TrustedSandbox;

})();
