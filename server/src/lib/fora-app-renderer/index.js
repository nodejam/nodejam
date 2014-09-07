(function() {
    "use strict";

    var _;

    var layout = require('./layout');
    var argv = require('optimist').argv;

    var renderFunc = argv['debug-client'] ? layout.render_DEBUG : layout.render;


    var Renderer = function(router) {
        this.router = router;
    };


    Renderer.prototype.addRoute = function(url, view) {
        var self = this;
        this.router.get(
            url,
            function*() {
                _ = yield* self.showView(view);
            }
        );
    };


    Renderer.prototype.showView = function*() {
        _ = yield* layout.render(view, pagePath);
    };



    module.exports = Renderer;

})();
