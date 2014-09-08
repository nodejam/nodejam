(function() {
    "use strict";

    var _;

    var layout = require('./layout');
    var argv = require('optimist').argv;

    var renderFunc = argv['debug-client'] ? layout.render_DEBUG : layout.render;


    var Renderer = function(router) {
        this.router = router;
    };


    Renderer.prototype.createRoutes = function(routes, basepath) {
        var result = [];

        routes.forEach(function(route) {
            var view = require(require("path").join(basepath, route.path));
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() { _ = yield* renderFunc(view, route.path); }
            });
        });

        return result;

    };



    module.exports = Renderer;

})();
