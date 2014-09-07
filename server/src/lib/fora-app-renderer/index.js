(function() {
    "use strict";

    var _;

    var layout = require('./layout');
    var argv = require('optimist').argv;

    var renderFunc = argv['debug-client'] ? layout.render_DEBUG : layout.render;


    var Renderer = function(router) {
        this.router = router;
    };


    Renderer.prototype.createRoutes = function(routes) {
        var result = [];

        routes.forEach(function(route) {
            result.push({
                method: route.method,
                url: route.url,
                handler: function*() { _ = yield* renderFunc(route.view, route.path); }
            });
        });

        return result;       

    };



    module.exports = Renderer;

})();
