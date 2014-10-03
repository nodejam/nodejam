(function() {
    "use strict";

    var _;

    var ApiConnector = require('./api-connector');

    var renderFunc = __DEBUG ? layout.render_DEBUG : layout.render;

    var Renderer = function(router, extensionsService) {
        this.router = router;
        this.extensionsService = extensionsService;
    };


    Renderer.prototype.createRoutes = function(routes, basepath) {
        var self = this;

        var libs = {
            extensions: {
                get: this.getExtension.bind(this)
            }
        };

        var result = [];

        routes.forEach(function(route) {
            var view = require(require("path").join(basepath, route.path));
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() {
                    this.api = new ApiConnector(this, self.router);
                    this.libs = libs;
                    this.body = yield* renderFunc.call(this, view, route.path);
                }
            });
        });

        return result;
    };


    Renderer.prototype.getExtension = function*(typeDef) {
        var result = yield* this.extensionsService.get(typeDef.name);
        if (result)
            return result.extension;
    };


    module.exports = Renderer;

})();
