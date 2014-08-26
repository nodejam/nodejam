(function() {
    "use strict";

    var _;

    var TrustedSandbox = require('./trusted-sandbox'),
        UntrustedSandbox = require('./untrusted-sandbox');


    var Sandbox = function(services) {
        this.services = services;
        this.extensionsService = services.get('extensions');
    };


    Sandbox.prototype.sanitizeContext = function(requestContext, routingContext) {
        var sanitized = {
            request: {},
            query: {}
        };

        sanitized.request.method = requestContext.request.method;

        var urlParts = routingContext.url.split("/");
        var lastUrlPart = urlParts[urlParts.length - 1];
        if (lastUrlPart.indexOf('?') > -1) {
            var queryParams = lastUrlPart.split("?")[1];
            var queryParts = queryParams.split("&").filter(function(p) { return p.split("=")[0] !== "token"; });
            urlParts[urlParts.length - 1] = lastUrlPart.split("?")[0] + "?" + queryParts.join("&");
            sanitized.request.url = urlParts.join("/");
            queryParts.forEach(function(p) {
                var pParts = p.split("=");
                sanitized.query[pParts[0]] = pParts.length > 1 ? pParts[1] : undefined;
            });
        }

        return sanitized;
    };


    Sandbox.prototype.executeRequest = function*(requestContext, routingContext) {
        var app = routingContext.app;
        requestContext = this.sanitizeContext(requestContext, routingContext);
        var appExtension = yield* this.extensionsService.getExtensionByName("app", app.type, app.version);

        //We can't pass appExtension to Untrusted contexts, since it will execute outside this process boundary.
        //For example, inside another process, or even a machine.
        var sandbox = appExtension ? new TrustedSandbox(appExtension, app) : new UntrustedSandbox(null, app);
        return yield* sandbox.executeRequest(requestContext, app);
    };


    module.exports = Sandbox;

})();
