(function () {
    "use strict";

    var pathToRegexp = require('path-to-regexp');

    var Router = function (context) {
        this.context = context;
        this.routes = [];
    };


    Router.prototype.get = function(url, handler) {
        this.add("GET", url, handler);
    };


    Router.prototype.post = function(url, handler) {
        this.add("POST", url, handler);
    };


    Router.prototype.del = function(url, handler) {
        this.add("DEL", url, handler);
    };


    Router.prototype.put = function(url, handler) {
        this.add("PUT", url, handler);
    };


    Router.prototype.add = function(method, url, handler) {
        this.routes.push({ method: method.toUpperCase(), re: pathToRegexp(url), url: url, handler: handler });
    };


    Router.prototype.getRoutes = function() {
        var self = this;
        return function*(next) {
            for(var i = 0; i < this.routes.length; i++) {
                var route = self.routes[i];
                if (route.method === this.request.method) {
                    var url = this.request.url.split('/').slice(2).join('/');
                    var m = route.re.exec(url);
                    if (m) {
                        var args = m.slice(1);
                        return yield* route.handler.apply(this, args);
                    }
                }
            }
            yield next;
        };
    };

    module.exports = Router;

})();
