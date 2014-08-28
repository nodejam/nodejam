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
        var routeConfig = require('fora-app-route-config');

        var home = require('./home');

        return routeConfig(
            function(router) {
                //users
                router.get("", home.index);
            },
            appInfo,
            {
                urlPrefix: "/",
                appUrlPrefix: "/"
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
