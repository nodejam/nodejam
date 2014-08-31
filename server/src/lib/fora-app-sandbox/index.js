(function() {
    "use strict";

    var _;

    var TrustedSandbox = require('./trusted-sandbox'),
        UntrustedSandbox = require('./untrusted-sandbox');


    var Sandbox = function(services, extensionModule) {
        this.services = services;
        this.extensionsService = services.get('extensionsService');
        this.extensionModule = extensionModule;
    };


    Sandbox.prototype.executeRequest = function*(requestContext, routingContext) {
        var extension = yield* this.extensionsService.getExtensionByName(
            "app",
            routingContext.app.type,
            routingContext.app.version
        );

        //We can't pass extension to Untrusted sandboxen, since it will execute outside this process boundary.
        //For example, inside another process, or even a machine.
        var sandbox = extension ?
            new TrustedSandbox(extension, this.extensionModule) : new UntrustedSandbox(this.extensionModule);
        return yield* sandbox.executeRequest(requestContext, routingContext);
    };


    module.exports = Sandbox;

})();
