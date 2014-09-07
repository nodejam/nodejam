(function() {
    "use strict";

    var _;

    var router, appInfo;

    var routeConfig = require('fora-app-route-config');

    var init = function*(_appInfo) {
        router = configureRouter();
        appInfo = _appInfo;
    };

    var configureRouter = function() {

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        var ui_home = require('./ui/home');

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

                //ui/home
                router.get("/ui/home", ui_home.index);
            },
            appInfo,
            {
                urlPrefix: "/api",
                appUrlPrefix: "/app",
                extensionModuleName: "api"
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
