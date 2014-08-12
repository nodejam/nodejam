(function () {
    "use strict";

    var _;

    var pathToRegexp = require('path-to-regexp');

    var Router = function (urlRoot) {
        this.urlRoot = urlRoot || "/";
        this.routes = [];
    };


    Router.prototype.get = function(url, handler) {
        this.addPattern("GET", url, handler);
    };


    Router.prototype.post = function(url, handler) {
        this.addPattern("POST", url, handler);
    };


    Router.prototype.del = function(url, handler) {
        this.addPattern("DEL", url, handler);
    };


    Router.prototype.put = function(url, handler) {
        this.addPattern("PUT", url, handler);
    };


    Router.prototype.addPattern = function(method, url, handler) {
        url = this.urlRoot + url;
        this.routes.push({ type: "pattern", method: method.toUpperCase(), re: pathToRegexp(url), url: url, handler: handler });
    };


    Router.prototype.when = function(predicate, handler) {
        this.routes.push({ type: "predicate", predicate: predicate, handler: handler });
    };


    var decode = function(val) {
      if (val) return decodeURIComponent(val);
    };


    Router.prototype.start = function() {
        var self = this;

        return function*(next) {
            for(var i = 0; i < self.routes.length; i++) {
                var route = self.routes[i];
                switch (route.type) {
                    case "predicate":
                        if (route.predicate(this)) {
                            _ = yield* route.handler.apply(this, args);
                            return yield next;
                        }
                        break;
                    case "pattern":
                        if (route.method === this.request.method) {
                            var m = route.re.exec(this.path);
                            if (m) {
                                var args = m.slice(1).map(decode);
                                _ = yield* route.handler.apply(this, args);
                                return yield next;
                            }
                        }
                        break;
                }
            }
            return yield next;
        };
    };

    module.exports = Router;

})();
