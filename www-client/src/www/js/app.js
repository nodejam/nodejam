(function() {
    "use strict";

    var _;

    var co = require('co'),
        logger = require('fora-app-logger'),
        Router = require('fora-router'),
        Renderer = require('fora-app-renderer'),
        ForaRequest = require('fora-request'),
        services = require('fora-app-services'),
        models = require('fora-app-models'),
        initializeApp = require('fora-app-initialize'),
        baseConfig = require('./config');


    /*  Container UI Routes */
    var addContainerUIRoutes = function*(router, urlPrefix, extensionsService) {
        var uiModule = yield* extensionsService.getModuleByName("container", "default", "1.0.0", "web")();

        var renderer = new Renderer(router);

        var uiRoutes = renderer.createRoutes(uiModule().routes);
        uiRoutes.forEach(function(route) {
            var url = /\/$/.test(urlPrefix) || /^\//.test(route.url) ? urlPrefix + route.url : urlPrefix + "/" + route.url;
            router[route.method](url, route.handler);
        });
    };



    var init = function() {
        co(function*() {
            var config = {
                services: {
                    extensions: {
                        modules: [
                            { kind: "container", modules: ["api", "web"] },
                            { kind: "app", modules: ["definition", "api", "web"] },
                            { kind: "record", modules: ["definition", "model", "web"] }
                        ]
                    }
                }
            };

            var initResult = yield* initializeApp(config, baseConfig);
            var router = new Router();

            var extensionsService = services.get('extensionsService');
            _ = yield* addContainerUIRoutes(router, "/", extensionsService);

            var routeFunc = router.route();

            var doRouting = function*() {
                var request = new ForaRequest();
                _ = yield* routeFunc.call(request, null);
            };

            var onChange = function() {
                co(doRouting)();
            };

            // Listen on hash change, page load:
            window.addEventListener('hashchange', onChange);
            window.addEventListener('load', onChange);

            logger.log("Fora started at " + new Date());
        })();
    };

    window.initForaApp = init;

})();
