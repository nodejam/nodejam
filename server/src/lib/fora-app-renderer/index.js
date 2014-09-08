(function() {
    "use strict";

    var _;

    var ApiConnector = require('./api-connector');
    var layout = require('./layout');
    var argv = require('optimist').argv;

    var renderFunc = argv['debug-client'] ? layout.render_DEBUG : layout.render;


    var Renderer = function(router) {
        this.router = router;
    };


    Renderer.prototype.createRoutes = function(routes, basepath) {
        var result = [];

        var apiConnector = new ApiConnector(this.router);
        routes.forEach(function(route) {
            var view = require(require("path").join(basepath, route.path));
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() {
                    this.api = apiConnector;
                    _ = yield* renderFunc(view, route.path);
                }
            });
        });

        return result;
    };


    module.exports = Renderer;

})();
