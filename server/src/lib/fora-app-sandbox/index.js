(function() {
    "use strict";

    var _;

    var TrustedSandbox = require('./trusted-sandbox'),
        UntrustedSandbox = require('./untrusted-sandbox');


    var Sandbox = function(services) {
        this.services = services;
        this.extensionsService = services.get('extensions');
    };


    Sandbox.prototype.executeRequest = function*(context, app) {
        var appExtension = yield* this.extensionsService.getExtensionByName("app", app.type, app.version);

        //We can't pass appExtension to Untrusted contexts, since it will execute outside this process boundary.
        //For example, inside another process, or even a machine.
        var sandbox = appExtension ? new TrustedSandbox(appExtension, app) : new UntrustedSandbox(null, app);
        return yield* sandbox.executeRequest(context, app);
    };


    module.exports = Sandbox;

})();
