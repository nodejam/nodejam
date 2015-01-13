(function() {
    "use strict";

    var HttpConnector = require('./http-connector'),
        viewApi = require('./view-api'),
        layout = require('./layout');


    var Renderer = function(router, isDebug) {
        this.router = router;
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
                        views: viewApi
                    };
                    this.body = yield self.renderFunc.call(null, this, route.handler, api);
                }
            });
        });

        return result;
    };


    module.exports = Renderer;

})();
