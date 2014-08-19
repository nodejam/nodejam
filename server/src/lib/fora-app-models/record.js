(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var RecordBase = require('./record-base').RecordBase,
        models = require('./'),
        randomizer = require('fora-app-randomizer'),
        typeHelpers = require('fora-app-type-helpers');

    //ctor
    var Record = function() {
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        RecordBase.apply(this, arguments);
    };

    Record.prototype = Object.create(RecordBase.prototype);
    Record.prototype.constructor = Record;

    __extends(Record, RecordBase);


    Record.typeDefinition = (function() {
        var originalDef = typeHelpers.clone(RecordBase.typeDefinition);
        originalDef.discriminator = function*(obj, typesService) {
            var def = yield* typesService.getTypeDefinition(obj.type);
            if (def.ctor !== App)
                throw new Error("App type definitions must have ctor set to App");
            return def;
        };
        return originalDef;
    })();


    Record.search = function*(criteria, settings, context) {
        var limit = getLimit(settings.limit, 100, 1000);

        var params = {};
        for (var k in criteria) {
            v = criteria[k];
            params[k] = v;
        }

        yield Record.find(
            params,
            { sort: settings.sort, limit: limit },
            context
        );
    };


    var getLimit = function(limit, _default, max) {
        var result = _default;
        if (limit) {
            result = limit;
            if (result > max)
                result = max;
        }
        return result;
    };


    Record.prototype.addMetaList = function*(metaList, context) {
        metaList.forEach(function(m) {
            if (this.meta.indexOf(m) === -1)
                this.meta.push(m);
        });
        return yield* this.save(context);
    };


    Record.prototype.removeMetaList = function*(metaList) {
        this.meta = this.meta.filter(function(m) {
            return metaList.indexOf(m) === -1;
        });
        return yield* this.save(context);
    };


    Record.prototype.save = function*(context) {
        //Broken here.. getModel isn't implemented
        var model = yield* extensions.getModel();
        _ = yield* model.save.call(this);

        //if stub is a reserved name, change it
        if (stub) {
            if (conf.reservedNames.indexOf(this.stub) > -1)
                throw new Error("Stub cannot be " + stub + ", it is reserved");

            var regex = /[a-z][a-z0-9|-]*/;
            if (!regex.test(this.stub))
                throw new Error("Stub is invalid");
        } else {
            this.stub = this.stub || randomizer.uniqueId(16);
        }

        var result = yield* RecordBase.prototype.save.call(this, context);

        if (this.state === 'published') {
            app = yield* models.App.findById(this.appId, context);
        }

        return result;
    };



    Record.prototype.getCreator = function*(context) {
        return yield* models.User.findById(this.createdById, context);
    };


    exports.Record = Record;

})();
