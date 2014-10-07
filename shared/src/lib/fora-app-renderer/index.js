(function() {
    "use strict";

    var _;

    var ApiConnector = require('./api-connector');
    var layout = require('./layout');


    var Renderer = function(router, extensionsService, isDebug) {
        this.router = router;
        this.extensionsService = extensionsService;
        this.renderFunc = isDebug ? layout.render_DEBUG : layout.render;
    };


    Renderer.prototype.createRoutes = function(routes) {
        var self = this;

        var libs = {
            extensions: {
                get: this.getExtension.bind(this)
            }
        };

        var result = [];

        routes.forEach(function(route) {
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() {
                    this.api = new ApiConnector(this, self.router);
                    this.libs = libs;
                    this.body = yield* self.renderFunc.call(this, route.handler);
                }
            });
        });

        return result;
    };


    Renderer.prototype.getExtension = function*(name) {
        var result = yield* this.extensionsService.get(name);
        if (result)
            return result.extension;
    };


    module.exports = Renderer;

})();
