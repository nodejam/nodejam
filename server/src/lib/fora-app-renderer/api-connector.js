(function() {
    "use strict";

    var _;


    var ApiConnector = function(router) {
        this.router = router;
        this.routeFn = router.route();
    };


    ApiConnector.prototype.get = function*(url, requestContext) {
    };


    module.exports = ApiConnector;

})();
