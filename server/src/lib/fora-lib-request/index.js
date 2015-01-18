(function() {
    "use strict";

    /*
        Fora Request
        A wrapper around koa's request.
    */

    var urlModule = require('url'),
        qs = require('querystring'),
        multipart = require('co-multipart'),
        body = require('co-body');

    var simplePathRegExp = /^(\/\/?(?!\/)[^\?#\s]*)(\?[^#\s]*)?$/;


    //via https://github.com/expressjs/parseurl/blob/master/index.js
    var fastparse = function (str) {
        // Try fast path regexp
        // See: https://github.com/joyent/node/pull/7878
        var simplePath = typeof str === 'string' && simplePathRegExp.exec(str);

        // Construct simple URL
        if (simplePath) {
            var pathname = simplePath[1];
            var search = simplePath[2] || null;
            var url = urlModule.Url !== undefined ? new urlModule.Url() : {};
            url.path = str;
            url.href = str;
            url.pathname = pathname;
            url.search = search;
            url.query = search && search.substr(1);

            return url;
        }

        return urlModule.parse(str);
    };


    var ForaRequest = function(koaRequest, params) {
        this.koaRequest = koaRequest;
        if (params) {
            if (params.url)
                this.url = params.url;

            if (params.method)
                this.method = method;

            if (params.requestBody)
                this.requestBody = requestBody;

            if (params.requestFiles)
                this.requestFiles = requestFiles;
        }

        if (!this.url)
            this.url = this.koaRequest.url;

        if (!this.method)
            this.method = this.koaRequest.method;

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


    //This is a TODO and an ERROR. Must not pass through koa cookies.
    Object.defineProperty(ForaRequest.prototype, "cookies", {
        get: function() {
            return this.koaRequest.cookies;
        }
    });


    ForaRequest.prototype.initBody = function*() {
        if (!this.requestBody)
            this.requestBody = (yield body(this.koaRequest)) || {};
        return this.requestBody;
    };


    ForaRequest.prototype.initFiles = function*() {
        this.requestFiles = (yield multipart(this.koaRequest)).files || [];
    };



    ForaRequest.prototype.getFormField = function*(name, request) {
        if (!request.requestBody)
            yield* request.initBody();
        return request.requestBody[name];
    };



    ForaRequest.prototype.completeRequest = function() {
        if (typeof this.body !== "undefined")
            this.koaRequest.body = this.body;
    };


    var __Clone = function() {};
    var clone = function(obj) {
        __Clone.prototype = obj;
        return new __Clone();
    };


    ForaRequest.prototype.clone = function*() {
        return clone(this);
    };



    module.exports = ForaRequest;

})();
