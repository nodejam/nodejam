(function () {
    "use strict";

    var pathToRegexp = require('path-to-regexp');

    var Router = function () {
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
        if (/\//.test(url)) url = url.substring(1); //Remove '/' from the beginning
        this.routes.push({ type: "pattern", method: method.toUpperCase(), re: pathToRegexp(url), url: url, handler: handler });
    };


    Router.prototype.when = function(predicate, handler) {
        this.routes.push({ type: "predicate", predicate: predicate, handler: handler });
    };


    Router.prototype.start = function() {
        var self = this;

        return function*(next) {
            for(var i = 0; i < self.routes.length; i++) {
                var route = self.routes[i];
                switch (route.type) {
                    case "predicate":
                        if (route.predicate(this)) {
                            return yield* route.handler.apply(this, args);
                        }
                        break;
                    case "pattern":
                        if (route.method === this.request.method) {
                            var m = route.re.exec(this.request.url);
                            if (m) {
                                var args = m.slice(1);
                                return yield* route.handler.apply(this, args);
                            }
                        }
                        break;
                }
            }
        };
    };

    module.exports = Router;

})();
