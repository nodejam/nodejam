(function() {
    "use strict";

    var _; //keep jshint happy, until they fix yield*

    var logger = require('../logger'),
        argv = require('optimist').argv,
        ForaTypeUtils = require('ForaTypeUtils'),
        odm = require('fora-models'),
        Mapper = require('./mapper'),
        errorHandler = require('./error'),
        router = require('./router'),
        koa = require('koa'),
        models = require('app-models'),
        fields = require('app-fields');


    //monitoring and reporting
    var setupInstanceStats = function() {
        var appInfo = {};
        if (process.env.NODE_ENV === 'development') {
            var randomizer = require('../randomizer');
            appInfo.instance = randomizer.uniqueId();
            appInfo.since = Date.now();
        } else {
            appInfo.instance = '00000000';
            appInfo.since = 0;
        }
        return appInfo;
    };


    //setup the request
    var RequestParser = require('fora-webrequestparser');
    var setupRequest = function*(next) {
        if (["POST", "PUT", "PATCH"].indexOf(this.method) > -1) {
            this.parser = new RequestParser(this, typeUtils);
        }
        _ = yield* next;
    };


    module.exports = function*(containerName, loader, conf, host, port) {
        var typeUtils = new ForaTypeUtils(loader);
        _ = yield* typeUtils.init([models, fields], models.Record);

        var db = new odm.Database(conf.db);
        var mapper = new Mapper(typeUtils);

        var auth = require('./auth')({ typeUtils: typeUtils, models: models, fields: fields, db: db, conf: conf });

        var appInfo = setupInstanceStats();
        //var controllerArgs = { typeUtils: typeUtils, models: models, fields: fields, db: db, conf: conf, auth: auth, mapper: mapper, loader: loader };

        var app = koa();
        app.use(setupRequest);
        app.use(errorHandler);

        var container = yield* loader.load(containerName);
        var routes = yield* container.getRoutes();
        app.use(router(routes));

        app.listen(port);
    };
})();
