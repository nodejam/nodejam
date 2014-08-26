(function() {
    "use strict";

    var _;

    var router;

    var init = function*() {
        router = configureRouter();
    };

    var configureRouter = function() {
        var services = require('fora-app-services'),
            conf = require('../../config');

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        var models = require('fora-app-models');

        var Router = require("fora-router");
        var router = new Router("/api");

        var Sandbox = require('fora-app-sandbox');
        var sandbox = new Sandbox(services);

        var typesService = services.get('types'),
            db = services.get('db');

        var context = { typesService: typesService, db: db };

        //healthcheck
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });


        //Rewrite: example.com/url -> /apps/example/url
        //If the request is for a different domain, it must be an app.
        router.when(function() {
            return this.request.hostname && (conf.domains.indexOf(this.request.hostname) === -1);
        }, function*(routingContext) {
            var app = yield* models.App.findOne({ domains: this.request.hostname }, context);
            routingContext.app = app; //Cache this to avoid db lookup later.
            routingContext.url = "/apps" + app.stub + this.request.url;
            return true; //continue matching.
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

        //Run the app in a sandbox.
        //Also rewrite the url: /apps/:appname/some/path -> /some/path
        router.when(function(routingContext) {
            return /^\/apps\//.test(routingContext.url || this.request.url);
        }, function*(routingContext) {
            var parts = (routingContext.url || this.request.url).split('/');
            routingContext.url = "/" + parts.slice(3).join("/");
            routingContext.app = routingContext.app || (yield* models.App.findOne({ stub: parts[2].split("?")[0] }, context));
            _ = yield* sandbox.executeRequest(this, routingContext);
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
