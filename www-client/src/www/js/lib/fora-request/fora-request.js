(function() {
    "use strict";

    /*
        Fora Request (Client)
        Basic properties for routing on the client side.

        Router needs url, path and method
    */

    var ForaRequest = function() {
        this.url = location.href.replace(/http.?\:\/\/[^\/]*/, "");
        this.path = location.pathname;
        this.method = "GET";
    };


    ForaRequest.prototype.clone = function() {
        return this;
    };


    module.exports = ForaRequest;

})();
