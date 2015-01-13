(function() {
    "use strict";

    var _;

    var visit = require('fora-data-utils').visit;
    var services = require('fora-lib-services');

    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.router = router;
        this.routeFn = router.route();
        this.typesService = services.getTypesService();
    };


    ApiConnector.prototype.get = function*(url) {
        return yield this.makeRequest("GET", url);
    };


    ApiConnector.prototype.makeRequest = function*(method, url) {
        var self = this;

        var match;

        if (__apiCache) {
            for(var i = 0; i < __apiCache.length; i++) {
                var current = __apiCache[i];
                if (current.requestContext.method === method && current.requestContext.url === url) {
                    match = current;
                    break;
                }
            }

            if (match) {
                return yield visit(
                    match.requestContext.body,
                    function*(item) {
                        if (item._mustReconstruct) {
                            var entitySchema = yield self.typesService.getEntitySchema(item.type);
                            var model = yield self.typesService.constructEntity(item, entitySchema);
                            return { value: model, stop: true };
                        }
                    }
                );
            }
        }

        //Do an AJAX call here and return results.
        throw new Error("We are not doing AJAX yet.");
    };


    ApiConnector.prototype.getRoutingContext = function*(url, method) {
        return {};
    };


    module.exports = ApiConnector;

})();
