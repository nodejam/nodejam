(function() {
    "use strict";

    var _;

    var router;

    var init = function*() {
        router = configureRouter();
    };

    var configureRouter = function() {
        var services = require('../../common/fora-services'),
            extensions = services.get('extensions'),
            conf = require('../../config');

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        var models = require('../../models');

        var Router = require("fora-router");
        var router = new Router("/api");


        //If the request is for a different domain, it must be an app.
        //Rewrite: example.com/url -> /apps/example/url
        router.when(function() {
            return this.req.hostname && (conf.domains.indexOf(this.req.hostname) === -1);
        }, function*(routingContext) {
            var app = yield* models.App.findOne({ domains: this.req.hostname }, services.context());
            routingContext.app = app; //Cache this to avoid db lookup later.
            this.req.url = "/apps" + app.stub + this.req.url;
            return true; //continue matching.
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


        //apps will do their own routing.
        var routeToApp = function*(app) {
            var appExtensions = yield* extensions.getByName(app.type);
            if (!appExtensions.api.__initted) {
                _ = yield* appExtensions.api.init();
                appExtensions.api.__initted = true;
            }
            var router = yield* appExtensions.api.getRouter();
            _ = yield* router.route().call(this);
        };


        //Before passing this on to the app, rewrite the url
        //eg: rewrite /apps/:appname/some/path -> /some/path
        router.when(function() {
            return /^\/apps\//.test(this.req.url);
        }, function*() {
            var parts = this.req.url.split('/');
            this.req.url = "/" + parts.slice(3).join("/");
            var app = routingContext.app ? routingContext.app : yield* models.App.findOne({ stub: parts[2] }, services.context());
            _ = yield* routeToApp.call(this, app);
        });

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
