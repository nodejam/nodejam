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
        var extension = yield* this.extensionsService.getExtensionByName(
            "app",
            requestContext.routingContext.app.type,
            requestContext.routingContext.app.version
        );

        //We can't pass extension to Untrusted sandboxen, since it will execute outside this process boundary.
        //For example, inside another process, or even a machine.
        var sandbox = extension ? new TrustedSandbox(extension, requestContext.app) : new UntrustedSandbox(null, requestContext.app);
        return yield* sandbox.executeRequest(requestContext);
    };


    module.exports = Sandbox;

})();
