(function() {
    "use strict";

    var _;

    var HttpConnector = require('./http-connector');
    var layout = require('./layout');


    var Renderer = function(router, extensionsService, isDebug) {
        this.router = router;
        this.extensionsService = extensionsService;
        this.renderFunc = isDebug ? layout.render_DEBUG : layout.render;
    };


    Renderer.prototype.createRoutes = function(routes) {
        var self = this;

        var result = [];

        routes.forEach(function(route) {
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() {
                    var api = {
                        http: new HttpConnector(this, self.router),
                        extensions: {
                            get: self.getExtension.bind(self)
                        }
                    };
                    this.body = yield* self.renderFunc.call(null, this, route.handler, api);
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
