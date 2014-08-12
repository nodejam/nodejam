(function() {
    "use strict";

    var router;

    var init = function*() {
        router = configureRouter();
    };

    var configureRouter = function() {
        var services = require('fora-services');
        var conf = services.get('configuration');
        var extensions = services.get('extensionsService');

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        var models = require('fora-app-models');

        var Router = require("fora-router");
        var router = new Router("/api");


        //apps will do their own routing.
        var routeToApp = function*(app) {
            var appExtension = yield* extensions.get(app.type);
            var router = appExtension.getRouter();
            yield* router.start();
        };

        //If the request is for a different domain, it must be an app.
        //There is no need to rewrite, since domain based urls don't have /apps/:appname prefix
        router.when(function(req) {
            return conf.domains.indexOf(req.hostname) === -1;
        }, function*(next) {
            var app = yield* models.App.get({ domains: this.req.hostname }, services.context());
            return yield* routeToApp(app);
        });

        //Before passing this on to the app, rewrite the url
        //eg: rewrite /apps/:appname/some/path -> /some/path
        router.when(function(req) {
            return /^\/apps\//.test(req.url);
        }, function*(next) {
            var parts = this.req.url.split('/');
            this.url = "/" + parts.slice(3).join("/");
            var app = yield* models.App.get({ stub: parts[2] });
            return yield* routeToApp(app);
        });

        //healthcheck
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });

        //users
        router.post("/credentials", credentials.create);
        router.post("/users", users.create);
        router.post("/login", users.login);
        router.get("/users/:username", users.item);

        //apps
        router.post("/apps", apps.create);

        //images
        router.post("/images", images.upload);

        return router;
    };

    var getRouter = function*() {
        return router;
    };

    module.exports = {
        init: init,
        getRouter: getRouter
    };

})();
