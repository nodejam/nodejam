(function() {
    "use strict";

    var path = require('path'),
        argv = require('optimist').argv,
        co = require('co'),
        koaSend = require("koa-send"),
        logger = require('fora-app-logger'),
        Router = require('fora-router'),
        Renderer = require('fora-app-renderer'),
        services = require('fora-app-services'),
        initializeApp = require('fora-app-initialize'),
        baseConfig = require('./config'),
        randomizer = require('fora-app-randomizer'),
        DbConnector = require('fora-app-db-connector');


    var staticPaths = ["public", "js", "vendor", "css", "images", "fonts"];


    /*
        Setup information useful for monitoring and debugging
    */
    var setupInstanceStats = function() {
        var appInfo = {};
        appInfo.instance = randomizer.uniqueId();
        appInfo.since = Date.now();
        return appInfo;
    };


    /*
        Calling /healthcheck returns { "jacksparrow": "alive", .... }
    */
    var addHealthCheck = function(router, appIinfo) {
        router.get("/healthcheck", function*() {
            var uptime = parseInt((Date.now() - since)/1000).toString() + "s";
            this.body = { jacksparrow: "alive", instance: appInfo.instance, since: appInfo.since, uptime: appInfo.uptime };
        });
    };


    /*
        Rewrite: example.com/url -> /apps/example/url
        If the request is for a different domain, it must be an app.
    */
    var addDomainRewrite = function(router) {
        var models = require('fora-app-models');
        var appStore = new DbConnector(models.App);
        router.when(
            function() {
                return this.hostname && (baseConfig.domains.indexOf(this.hostname) === -1);
            },
            function*() {
                this.app = yield* appStore.findOne({ domains: this.hostname });
                return true; //continue matching.
            }
        );
    };


    /*  Container API Routes */
    var addContainerAPIRoutes = function*(router, urlPrefix) {
        var extensionsService = services.getExtensionsService();
        var apiModule = yield* extensionsService.getModule("container", "default", "1.0.0", "api");

        apiModule.routes.forEach(function(route) {
            router[route.method](path.join(urlPrefix, route.url), route.handler);
        });
    }


    /*  Container UI Routes */
    var addContainerUIRoutes = function*(router, urlPrefix) {
        var extensionsService = services.getExtensionsService();
        var webModule = yield* extensionsService.getModule("container", "default", "1.0.0", "web");

        var renderer = new Renderer(router, argv['debug-client']);

        var uiRoutes = renderer.createRoutes(webModule.routes);
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
        var models = require('fora-app-models');
        var appStore = new DbConnector(models.App);
        var sessionStore = new DbConnector(models.Session);
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
                    this.app = yield* appStore.findOne({ stub: this.path.split("/")[prefixPartsCount] });
                    if (this.app) {
                        var urlParts = this.url.split("/");
                        this.url = this.url.replace(appRootRegex, "/");
                    } else {
                        throw new Error("Invalid application at " + this.url);
                    }
                }

                var token = this.query.token || this.cookies.get('token');
                if (token)
                    this.session = yield* sessionStore.findOne({ token: token });

                return yield* sandbox.executeRequest(this);
            }
        );
    };



    /*
        Static file routes

    */
    var addStaticRoutes = function*(router) {
        router.when(
            function() {
                var path = this.path.split("/");
                return path.length >= 2 && ["public", "js", "vendor", "css", "images", "fonts"].indexOf(path[1]) > -1;
            },
            function*() {
                var path = this.path.split("/");
                switch(path[1]) {
                    case "public":
                        yield koaSend(this, this.path, { root: baseConfig.services.file.publicDirectory });
                    default:
                        yield koaSend(this.koaRequest, this.path, { root: '../www-client/app/www' });
                }
                return false;
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
                            { kind: "app", modules: ["definition", "model", "api", "web"] },
                            { kind: "record", modules: ["definition", "model", "web"] }
                        ]
                    }
                }
            };

            var appInfo = setupInstanceStats();

            var initResult = yield* initializeApp(config, baseConfig);
            var router = new Router();
            addHealthCheck(router, appInfo);
            addDomainRewrite(router);

            if (baseConfig.serveStaticFiles) {
                yield* addStaticRoutes(router);
            }

            yield* addContainerAPIRoutes(router, "/api/v1");
            yield* addExtensionRoutes(router, "/api/app", "api");

            yield* addContainerUIRoutes(router, "/");
            yield* addExtensionRoutes(router, "/", "web");

            /* Init koa */
            var koa = require('koa');
            var app = koa();

            var errorHandler = require('fora-app-error-handler');
            app.use(errorHandler);

            app.use(router.koaRoute());
            app.listen(port);

            logger.log("Fora started at " + new Date() + " on " + host + ":" + port);
        }).then(null, function(err) { console.log(err); });
    };

    init();

})();
