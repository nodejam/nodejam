(function() {
    "use strict";

    var _;

    var co = require('co');
    var logger = require('fora-app-logger');
    var Server = require('fora-app-server');
    var Router = require('fora-router');
    var baseConfig = require('../config');

    var host = process.argv[2];
    var port = process.argv[3];

    if (!host || !port) {
        logger.log("Usage: app.js host port");
        process.exit();
    }

    var services = require('fora-app-services'),
        models = require('fora-app-models');

    var Parser = require('fora-request-parser');

    var Renderer = require('fora-app-renderer');

    /*
        Calling /healthcheck returns { "jacksparrow": "alive", .... }
    */
    var addHealthCheck = function(router, server) {
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: server.appInfo.instance, since: server.appInfo.since, uptime: server.appInfo.uptime };
        });
    };



    /*
        Rewrite: example.com/url -> /apps/example/url
        If the request is for a different domain, it must be an app.
    */
    var addDomainRewrite = function(router) {
        var typesService = services.get('typesService'),
            db = services.get('db');
        var context = { typesService: typesService, db: db };

        router.when(
            function() {
                return this.hostname && (baseConfig.domains.indexOf(this.hostname) === -1);
            },
            function*() {
                this.app = yield* models.App.findOne({ domains: this.hostname }, context);
                return true; //continue matching.
            }
        );
    };


    /*
        Run the app in a sandbox.
        Also rewrite the url: /apps/:appname/some/path -> /some/path, /apps/:appname?x -> /?x
    */
    var addExtensionRoutes = function(router, appUrlPrefix, extensionModuleName) {
        var typesService = services.get('typesService'),
            db = services.get('db');
        var context = { typesService: typesService, db: db };

        var Sandbox = require('fora-app-sandbox');
        var sandbox = new Sandbox(services, extensionModuleName);

        appUrlPrefix = /\/$/.test(appUrlPrefix) ? appUrlPrefix : appUrlPrefix + "/";
        var prefixPartsCount = appUrlPrefix.split("/").length - 1;
        var appPathRegex = new RegExp("^" + (appUrlPrefix));
        var appRootRegex = new RegExp("^" + appUrlPrefix + "[a-z0-9-]*/?");
        router.when(
            function() {
                return appPathRegex.test(this.url);
            },
            function*() {
                if (!this.app) {
                    this.app = yield* models.App.findOne({ stub: this.path.split("/")[prefixPartsCount] }, context);
                    if (this.app) {
                        var urlParts = this.url.split("/");
                        this.url = this.url.replace(appRootRegex, "/");
                    } else {
                        throw new Error("Invalid application");
                    }
                }

                this.parser = new Parser(this, typesService);

                var token = this.query.token || this.cookies.get('token');
                if (token)
                    this.session = yield* models.Session.findOne({ token: token }, context);

                return yield* sandbox.executeRequest(this);
            }
        );
    };


    co(function*() {
        var config = {
            services: {
                extensions: {
                    modules: [
                        { kind: "app", modules: ["api"] },
                        { kind: "record", modules: ["definition", "model", "web/views"] }
                    ]
                }
            },
            host: host,
            port: port
        };

        var server = new Server(config, baseConfig);
        _ = yield* server.init();

        var router = new Router();

        addHealthCheck(router, server);

        addDomainRewrite(router);

        //Setup API routes.
        require('./api/routes').forEach(function(route) {
            router[route.method](route.url, route.handler);
        });
        addExtensionRoutes(router, "/api/app", "api");

        //Setup UI routes
        var renderer = new Renderer(router, services.get('extensionsService'));
        var uiRoutes = renderer.createRoutes(require('./web/routes'), require("path").resolve(__dirname, "web/views"));
        uiRoutes.forEach(function(route) {
            router[route.method](route.url, route.handler);
        });
        addExtensionRoutes(router, "/", "web");

        //GO!
        server.addRouter(router);
        server.listen();

        logger.log("Fora API started at " + new Date() + " on " + host + ":" + port);
    })();

})();
