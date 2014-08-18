(function() {
    "use strict";

    var _;

    var router;

    var init = function*() {
        router = configureRouter();
    };

    var configureRouter = function() {
        var services = require('../../common/fora-services'),
            conf = require('../../config');

        var credentials = require('./credentials'),
            users = require('./users'),
            apps = require("./apps"),
            images = require("./images");

        var Sandbox = require('fora-app-sandbox');

        var models = require('../../models');

        var Router = require("fora-router");
        var router = new Router("/api");


        //healthcheck
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });


        //Rewrite: example.com/url -> /apps/example/url
        //If the request is for a different domain, it must be an app.
        router.when(function() {
            return this.req.hostname && (conf.domains.indexOf(this.req.hostname) === -1);
        }, function*(routingContext) {
            var app = yield* models.App.findOne({ domains: this.req.hostname }, services.context());
            routingContext.app = app; //Cache this to avoid db lookup later.
            this.req.url = "/apps" + app.stub + this.req.url;
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
        router.when(function() {
            return /^\/apps\//.test(this.req.url);
        }, function*(routingContext) {
            var parts = this.req.url.split('/');
            this.req.url = "/" + parts.slice(3).join("/");
            var app = routingContext.app ? routingContext.app : yield* models.App.findOne({ stub: parts[2] }, services.context());
            var sandbox = new Sandbox(app, services);
            _ = yield* sandbox.executeRequest(this);
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
