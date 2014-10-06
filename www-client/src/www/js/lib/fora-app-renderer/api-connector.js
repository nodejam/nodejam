(function() {
    "use strict";

    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url) {
        return yield* this.makeRequest("GET", url);
    };


    ApiConnector.prototype.makeRequest = function*(method, url) {
        var requestContext = this.requestContext.clone();
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
