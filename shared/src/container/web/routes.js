(function() {
    "use strict";

    var indexView = require('./views/home/index');

    var Renderer = require('fora-app-renderer');
    var renderer = new Renderer();

    module.exports = renderer.createRoutes([
        { method: "get", url: "", path: "/home/index", view: indexView }
    ]);

})();
