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

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        return routeConfig(
            function(router) {
                //users
                router.post("/credentials", credentials.create);
                router.post("/users", users.create);
                router.post("/login", users.login);
                router.get("/users/:username", users.item);

                //apps
                router.post("/apps", apps.create);

                //images
                router.post("/images", images.upload);
            },
            appInfo,
            {
                urlPrefix: "/api",
                isAppUrl: function(url) {
                    return /^\/apps\//.test(url);
                }
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
