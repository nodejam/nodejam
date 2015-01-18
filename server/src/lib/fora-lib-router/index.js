(function () {
    "use strict";

    var ForaRequest = require("fora-lib-request");
    var pathToRegexp = require('path-to-regexp');

    var Router = function (urlRoot) {
        urlRoot = urlRoot || "";
        this.urlRoot = /\/$/.test(urlRoot) ? urlRoot : (urlRoot + "/");
        this.urlRootRegex = new RegExp("^" + this.urlRoot);
        this.routes = [];
        this.onRequestHandlers = [];
    };


    Router.prototype.get = function(url, handler) {
        this.addPattern("GET", url, handler);
    };


    Router.prototype.post = function(url, handler) {
        this.addPattern("POST", url, handler);
    };


    Router.prototype.del = function(url, handler) {
        this.addPattern("DELETE", url, handler);
    };


    Router.prototype.put = function(url, handler) {
        this.addPattern("PUT", url, handler);
    };


    Router.prototype.addPattern = function(method, url, handler) {
        this.routes.push({ type: "pattern", method: method.toUpperCase(), re: pathToRegexp(url), url: url, handler: handler });
    };


    Router.prototype.onRequest = function(fn) {
        this.onRequestHandlers.push(fn);
    };


    Router.prototype.when = function(predicate, handler) {
        this.routes.push({ type: "predicate", predicate: predicate, handler: handler });
    };


    var decode = function(val) {
      if (val) return decodeURIComponent(val);
    };


    Router.prototype.doRouting = function*(request, next) {
        for(let i = 0; i < this.onRequestHandlers.length; i++) {
            yield* this.onRequestHandlers[i].call(this, next);
        }

        if (this.urlRootRegex.test(request.url)) {
            //Remove the prefix.
            for(var i = 0; i < this.routes.length; i++) {
                var route = this.routes[i];
                switch (route.type) {
                    case "predicate":
                        if (route.predicate.call(request)) {
                            var matchOtherRoutes = yield* route.handler.call(request);
                            if (!matchOtherRoutes)
                                return next ? (yield next) : void 0;
                        }
                        break;
                    case "pattern":
                        if (route.method === request.method) {
                            var m = route.re.exec(request.path || "");
                            if (m) {
                                var args = m.slice(1).map(decode);
                                yield* route.handler.apply(request, args);
                                return next ? (yield next) : void 0;
                            }
                        }
                        break;
                }
            }
        }
        return next ? (yield next) : void 0;
    };


    //If it is koaRoute, we wrap the request into a ForaRequest and unwrap it once done.
    Router.prototype.koaRoute = function() {
        var self = this;
        return function*(next) {
            var request = new ForaRequest(this);
            yield* self.doRouting(request, next);
            request.completeRequest();
        };
    };


    Router.prototype.route = function() {
        var self = this;
        return function*(next) {
            yield* self.doRouting(this, next);
        };
    };


    module.exports = Router;

})();
