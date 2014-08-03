(function() {
    "use strict";

    var router;

    var init = function*() {
        router = yield* setRouter();
    };

    var setRouter = function*() {
        var Router = require("fora-router");

        var credentials = require('./credentials')(api);
        var users = require('./users')(api);
        var apps = require("./apps")(api);
        var images = require("./images")(api);

        var router = new Router();

        //healthcheck
        router.get("healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });

        //users
        router.post("credentials", credentials.create);
        router.post("users", users.create);
        router.post("login", users.login);
        router.get("users/:username", users.item);

        //apps
        router.post("apps", apps.create);

        //images
        router.post("images", images.upload);

        //pass everything that starts with "apps/" to app extensions after stripping apps/ prefix
        router.when(function(req) {
            return /^apps\//.test(req.url);
        }, function*() {
            /*
                If we are not on the root domain, we must rewrite the url:
                    www.poe3.com => www.4ah.org/apps/poetry
            */
            if (false) {

            } else {
                var args = router.parse(req.url);
                var app = args[0];
            }
        });

        return router;
    };

    var getRouter = function*() {
        return router;
    };

    module.exports = {
        getRouter: getRouter
    };

})();
