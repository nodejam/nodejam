(function() {
    "use strict";

    var _;

    var path = require('path'),
        argv = require('optimist').argv,
        co = require('co'),
        logger = require('fora-app-logger'),
        Router = require('fora-router'),
        Parser = require('fora-request-parser'),
        Renderer = require('fora-app-renderer'),
        services = require('fora-app-services'),
        models = require('fora-app-models'),
        initializeApp = require('fora-app-initialize'),
        baseConfig = require('./config');

    /*
        Calling /healthcheck returns { "jacksparrow": "alive", .... }
    */
    var addHealthCheck = function(router, appIinfo) {
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000) + "s";
            this.body = { jacksparrow: "alive", instance: appInfo.instance, since: appInfo.since, uptime: appInfo.uptime };
        });
    };


    /*
        Rewrite: example.com/url -> /apps/example/url
        If the request is for a different domain, it must be an app.
    */
    var addDomainRewrite = function(router) {
        router.when(
            function() {
                return this.hostname && (baseConfig.domains.indexOf(this.hostname) === -1);
            },
            function*() {
                this.app = yield* models.App.findOne({ domains: this.hostname });
                return true; //continue matching.
            }
        );
    };


    /*  Container API Routes */
    var addContainerAPIRoutes = function*(router, urlPrefix, extensionsService) {
        var routes = yield* extensionsService.getModuleByName("container", "default", "1.0.0", "api");
        routes.forEach(function(route) {
            router[route.method](path.join(urlPrefix, route.url), route.handler);
        });
    }


    /*  Container UI Routes */
    var addContainerUIRoutes = function*(router, urlPrefix, extensionsService) {
        var routes = yield* extensionsService.getModuleByName("container", "default", "1.0.0", "web");

        var renderer = new Renderer(router, argv['debug-client']);

        var uiRoutes = renderer.createRoutes(routes);
        uiRoutes.forEach(function(route) {
            router[route.method](path.join(urlPrefix, route.url), route.handler);
        });
    }


    /*
        Extension Routes
        - Check if the route is an app
        - Run the app in a sandbox.
        - Also rewrite the url: /apps/:appname/some/path -> /some/path, /apps/:appname?x -> /?x
    */
    var addExtensionRoutes = function*(router, appUrlPrefix, extensionModuleName) {
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
                    this.app = yield* models.App.findOne({ stub: this.path.split("/")[prefixPartsCount] });
                    if (this.app) {
                        var urlParts = this.url.split("/");
                        this.url = this.url.replace(appRootRegex, "/");
                    } else {
                        throw new Error("Invalid application");
                    }
                }

                this.parser = new Parser(this, services.get('typesService'));

                var token = this.query.token || this.cookies.get('token');
                if (token)
                    this.session = yield* models.Session.findOne({ token: token });

                return yield* sandbox.executeRequest(this);
            }
        );
    };


    var init = function() {
        co(function*() {
            var host = process.argv[2];
            var port = process.argv[3];

            if (!host || !port) {
                logger.log("Usage: app.js host port");
                process.exit();
            }

            var config = {
                services: {
                    extensions: {
                        modules: [
                            { kind: "container", modules: ["api", "web"] },
                            { kind: "app", modules: ["definition", "api"] },
                            { kind: "record", modules: ["definition", "model", "web/views"] }
                        ]
                    }
                },
                host: host,
                port: port
            };

            var initResult = yield* initializeApp(config, baseConfig);
            var router = new Router();
            addHealthCheck(router, initResult.appInfo);
            addDomainRewrite(router);

            var extensionsService = services.get('extensionsService');

            //Setup API routes.
            yield* addContainerAPIRoutes(router, "/api/v1", extensionsService);
            yield* addExtensionRoutes(router, "/api/app", "api");

            yield* addContainerUIRoutes(router, "/", extensionsService);
            yield* addExtensionRoutes(router, "/", "web");

            /* Init koa */
            var koa = require('koa');
            var app = koa();
            var errorHandler = require('fora-app-error-handler');
            app.use(errorHandler);
            app.use(router.koaRoute());
            app.listen(config.port);

            logger.log("Fora started at " + new Date() + " on " + host + ":" + port);
        })();
    };

    init();

})();
