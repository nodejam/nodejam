(function() {
    "use strict";

    var _;


    var ApiConnector = function(requestContext, router) {
        this.requestContext = requestContext;
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url, requestContext) {
        var routingContext = {
            url: url,
        };
        routeFn.call(requestContext || this.requestContext, null, routingContext);
    };


    ApiConnector.prototype.getRoutingContext = function*(url, method) {
        return {
            url: url,
        }
    };


    module.exports = ApiConnector;

})();
