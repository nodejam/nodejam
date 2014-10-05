(function() {
    "use strict";

    var _;

    var co = require('co');
    var logger = require('fora-app-logger');
    var Client = require('fora-app-client');
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

            var client = new Client(config, baseConfig);
            _ = yield* client.init();

            var router = new Router();

            var extensionsService = services.get('extensionsService');
            _ = yield* addContainerUIRoutes(router, "/", extensionsService);

            //GO!
            client.addRouter(router);
            client.listen();

            logger.log("Fora started at " + new Date());
        })();
    };

    window.initForaApp = init;

})();
