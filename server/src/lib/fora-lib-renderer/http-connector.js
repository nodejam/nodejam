(function() {
    "use strict";

    var visit = require('fora-data-utils').visit;


    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.requestContext.apiCache = this.requestContext.apiCache || [];
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url) {
        var requestContext = yield* this.makeRequest("GET", url);

        //On the client, we can't tell if the deserialized JSON needs to go through a constructor.
        //So, set a flag __mustReconstruct.
        var response = yield* visit(
            requestContext.body,
            function*(x) {
                if (x && x.getEntitySchema) {
                    return {
                        value: x,
                        stop: true,
                        fnAfterVisit: function*(o) {
                            o._mustReconstruct = true;
                            return o;
                        }
                    };
                }
            }
        );

        /*
            This could be use to write out a stringified JSON response directly on the web page.
            A client side script calling the same method doesn't then do the actual fetch.
        */
        this.requestContext.apiCache.push({
            requestContext: {
                url: requestContext.url,
                method: requestContext.method,
                query: requestContext.query,
                body: response
            }
        });

        return response;
    };


    ApiConnector.prototype.makeRequest = function*(method, url) {
        var requestContext = yield* this.requestContext.clone();
        requestContext.url = url;
        requestContext.method = method;
        yield* this.routeFn.call(requestContext);

        return requestContext;
    };


    ApiConnector.prototype.getRoutingContext = function*(url, method) {
        return {};
    };


    module.exports = ApiConnector;

})();
