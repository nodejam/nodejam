(function() {
    "use strict";

    var _;

    var configure = function(fn, appInfo, options) {
        var services = require('fora-app-services'),
            conf = require('../../config'),
            models = require('fora-app-models');

        var typesService = services.get('types'),
            db = services.get('db');
        var context = { typesService: typesService, db: db };

        var Router = require("fora-router");
        var router = new Router(options.urlPrefix);

        var Sandbox = require('fora-app-sandbox');
        var sandbox = new Sandbox(services);

        //healthcheck
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: params.app.instance, since: params.app.since, uptime: params.app.uptime };
        });


        //Rewrite: example.com/url -> /apps/example/url
        //If the request is for a different domain, it must be an app.
        router.when(
            function() {
                return this.hostname && (conf.domains.indexOf(this.hostname) === -1);
            },
            function*() {
                this.routingContext.app = yield* models.App.findOne({ domains: this.hostname }, context);
                return true; //continue matching.
            }
        );

        fn(router);

        //Run the app in a sandbox.
        //Also rewrite the url: /apps/:appname/some/path -> /some/path, /apps/:appname?x -> /?x
        router.when(
            function() {
                return options.isAppUrl(this.url);
            },
            function*() {
                if (!this.routingContext.app) {
                    this.routingContext.app = yield* models.App.findOne({ stub: this.path.split("/")[2] }, context);
                    var urlParts = this.url.split("/");
                    this.url = this.url.replace(/^\/apps\/[a-z0-9\-]*\/?/,"/");
                }

                var token = this.query.token || this.cookies.get('token');
                if (token)
                    this.session = yield* models.Session.findOne({ token: token }, { typesService: typesService, db: db });

                return yield* sandbox.executeRequest(this);
            }
        );

        return router;

    };

    module.exports = configure;

})();
