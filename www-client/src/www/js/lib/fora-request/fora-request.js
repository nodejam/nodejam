(function() {
    "use strict";

    /*
        Fora Request (Client)
        Basic properties for routing on the client side.

        Router needs url, path and method
    */

    var ForaRequest = function(params) {
        params = params || {};
        var parser = document.createElement('a');
        parser.href = params.url || location.href;
        this.url = params.url || location.href.replace(/http.?\:\/\/[^\/]*/, "");
        this.path = parser.pathname;
        this.method = "GET";
    };


    ForaRequest.prototype.clone = function() {
        return new ForaRequest({ url: this.url, path: this.path });
    };


    module.exports = ForaRequest;

})();
