(function() {
    "use strict";

    var _;

    var router;
    var appInfo;

    var init = function*(_appInfo) {
        router = configureRouter();
        appInfo = _appInfo;
    };

    var configureRouter = function() {
        var argv = require('optimist').argv;
        var routeConfig = require('fora-app-route-config');

        var layout = require('./layout');
        var home = require('./home');

        var renderFunc = argv['debug-client'] ? layout.render_DEBUG : layout.render;

        return routeConfig(
            function(router) {
                router.onRequest(function*(next){
                    this.render = renderFunc;
                });
                router.get("", home.index);
            },
            appInfo,
            {
                urlPrefix: "/",
                appUrlPrefix: "/",
                extensionModuleName: "web"
            }
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
