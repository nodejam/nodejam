(function() {
    "use strict";

    /*
        Fora Request (Client)
        Basic properties for routing on the client side.
    */

    var ForaRequest = function(params) {
        if (params) {
            if (params.url)
                this.url = params.url;

            if (params.method)
                this.method = method;
        }
    };


    Object.defineProperty(ForaRequest.prototype, "url", {
        get: function() {
            return this.requestUrl;
        },
        set: function(val) {
            this.requestUrl = val;
            this.parsedRequestUrl = null;
            this.requestQuery = null;
        }
    });


    Object.defineProperty(ForaRequest.prototype, "path", {
        get: function() {
            if (!this.parsedRequestUrl) {
                this.parsedRequestUrl = fastparse(this.requestUrl);
            }
            return this.parsedRequestUrl.pathname;
        }
    });



    Object.defineProperty(ForaRequest.prototype, "querystring", {
        get: function() {
            if (!this.parsedRequestUrl) {
                this.parsedRequestUrl = fastparse(this.requestUrl);
            }
            return this.parsedRequestUrl.query;
        }
    });


    Object.defineProperty(ForaRequest.prototype, "query", {
        get: function() {
            if (!this.requestQuery) {
                var str = this.querystring;
                this.requestQuery = str ? qs.parse(str) : {};
            }
            return this.requestQuery;
        }
    });


    module.exports = ForaRequest;

})();
