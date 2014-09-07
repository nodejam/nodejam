(function() {
    "use strict";

    var _;

    var router, appInfo;

    var routeConfig = require('fora-app-route-config');
    var Renderer = require('fora-app-renderer');

    var indexView = require('./views/home/index');

    var init = function*(_appInfo) {
        router = configureRouter();
        appInfo = _appInfo;
    };

    var configureRouter = function() {

        return routeConfig(
            function(router) {
                var renderer = new Renderer(router);

                //home
                renderer.addRoute("get", "", indexView);
            },
            appInfo,
            { extensionModuleName: "web" }
        );
    };

    var getRouter = function*() {
        return router;
    };

    module.exports = {
        init: init,
        getRouter: getRouter
    };

})();
