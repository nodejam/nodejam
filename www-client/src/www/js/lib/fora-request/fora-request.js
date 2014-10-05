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

    module.exports = ForaRequest;

})();
