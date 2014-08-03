(function() {
    "use strict";

    var router;

    var init = function*() {
        router = yield* setRouter();
    };

    var setRouter = function*() {
        var Router = require("fora-router");

        var auth = require('./auth');
        var users = require('./users');
        var apps = require("./apps");

        var router = new Router();

        //healthcheck
        router.get("healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });

        //home
        router.get("", home.index);

        //login
        router.get("auth/twitter", auth.twitter);
        router.get("auth/twitter/callback", auth.twitterCallback);

        //users
        router.get("users/login", users.login);
        router.get("~:username", users.item);

        //apps
        router.get("apps", apps.index);
        router.get("apps/new", apps.create);

        return router;

    };

    var getRouter = function*() {
        return router;
    };

    module.exports = {
        getRouter: getRouter
    };

})();
