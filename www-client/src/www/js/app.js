(function() {
    "use strict";

    var _;

    var co = require('co');
    var logger = require('fora-app-logger');
    var initializeApp = require('fora-app-initialize');
    var Router = require('fora-router');
    var baseConfig = require('./config');

    var services = require('fora-app-services'),
        models = require('fora-app-models');

    var Renderer = require('fora-app-renderer');



    /*  Container UI Routes */
    var addContainerUIRoutes = function*(router, urlPrefix, extensionsService) {
        var routes = yield* extensionsService.getModuleByName("container", "default", "1.0.0", "web");

        var renderer = new Renderer(router, extensionsService);

        var uiRoutes = renderer.createRoutes(routes);
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
                            { kind: "app", modules: ["definition", "api"] },
                            { kind: "record", modules: ["definition", "model", "web/views"] }
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
