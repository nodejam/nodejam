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

        var api_credentials = require('./api/credentials'),
            api_users = require('./api/users'),
            api_apps = require("./api/apps"),
            api_images = require("./api/images");

        var ui_home = require('./ui/home');

        return routeConfig(
            function(router) {

                /* API Routes
                   ---------- */

                //users
                router.post("/api/credentials", api_credentials.create);
                router.post("/api/users", api_users.create);
                router.post("/api/login", api_users.login);
                router.get("/api/users/:username", api_users.item);

                //apps
                router.post("/api/apps", api_apps.create);

                //images
                router.post("/api/images", api_images.upload);

                /* UI Routes
                   --------- */

                //home
                router.get("/ui/home", ui_home.index);
            },
            appInfo,
            {
                urlPrefix: "/",
                appUrlPrefix: "/apps",
                extensionModuleName: "app"
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
