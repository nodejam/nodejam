(function() {
    "use strict";

    var _;

    var TrustedSandbox = require('./trusted-sandbox'),
        UntrustedSandbox = require('./untrusted-sandbox');


    var Sandbox = function(services) {
        this.services = services;
        this.extensionsService = services.get('extensionsService');
    };


    Sandbox.prototype.executeRequest = function*(requestContext) {
        var appExtension = yield* this.extensionsService.getExtensionByName(
            "app",
            requestContext.routingContext.app.type,
            requestContext.routingContext.app.version
        );

        //We can't pass appExtension to Untrusted sandboxen, since it will execute outside this process boundary.
        //For example, inside another process, or even a machine.
        var sandbox = appExtension ? new TrustedSandbox(appExtension, requestContext.app) : new UntrustedSandbox(null, requestContext.app);
        return yield* sandbox.executeRequest(requestContext);
    };


    module.exports = Sandbox;

})();
