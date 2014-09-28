(function() {
    "use strict";

    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url, requestContext) {
        return yield* this.makeRequest("GET", url, requestContext);
    };


    ApiConnector.prototype.makeRequest = function*(method, url, requestContext) {
        requestContext = (requestContext || this.requestContext).clone();
        requestContext.url = url;
        requestContext.method = method;
        _ = yield* this.routeFn.call(requestContext);
        return requestContext.body;
    };


    ApiConnector.prototype.getRoutingContext = function*(url, method) {
        return {};
    };


    module.exports = ApiConnector;

})();
