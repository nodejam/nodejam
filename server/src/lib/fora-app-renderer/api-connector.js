(function() {
    "use strict";

    var _;


    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url, requestContext) {
        routeFn.call(requestContext || this.requestContext);
    };


    ApiConnector.prototype.getRoutingContext = function*(url, method) {
        return {};
    };


    module.exports = ApiConnector;

})();
