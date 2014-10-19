(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };


    var RecordBase = require('./record-base').RecordBase,
        models = require('./'),
        randomizer = require('fora-app-randomizer'),
        dataUtils = require('fora-data-utils'),
        services = require('fora-app-services');

    //ctor
    var Record = function() {
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        RecordBase.apply(this, arguments);
    };

    Record.prototype = Object.create(RecordBase.prototype);
    Record.prototype.constructor = Record;

    __extends(Record, RecordBase);



    Record.search = function*(criteria, settings) {
        var limit = getLimit(settings.limit, 100, 1000);

        var params = {};
        for (var k in criteria) {
            v = criteria[k];
            params[k] = v;
        }

        _ = yield* Record.find(params, { sort: settings.sort, limit: limit });
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


    var getMappableFields = function*(typeDefinition, acc, prefix) {
        acc = acc || [];
        prefix = prefix || [];

        for (var field in typeDefinition.schema.properties) {
            if (!typeDefinition.ownProperties || typeDefinition.ownProperties.indexOf(field) > -1) {
                var def = typeDefinition.schema.properties[field];
                if (dataUtils.isPrimitiveType(def.type)) {
                    if (def.type === "array" && dataUtils.isCustomType(def.items.type)) {
                            prefix.push(field);
                            _ = yield* getMappableFields(def.items.typeDefinition, acc, prefix);
                            prefix.pop(field);
                    } else {
                        acc.push(prefix.concat(field).join('_'));
                    }
                } else if (dataUtils.isCustomType(def.type)) {
                    prefix.push(field);
                    _ = yield* getMappableFields(def.typeDefinition, acc, prefix);
                    prefix.pop(field);
                }
            }
        }

        return acc;
    };


    Record.prototype.getMappableFields = function*() {
        var typesService = services.get('typesService');
        return yield* getMappableFields(yield* this.getTypeDefinition(typesService));
    };


    Record.prototype.addMetaList = function*(metaList) {
        metaList.forEach(function(m) {
            if (this.meta.indexOf(m) === -1)
                this.meta.push(m);
        }, this);
        return yield* this.save();
    };



    Record.prototype.removeMetaList = function*(metaList) {
        this.meta = this.meta.filter(function(m) {
            return metaList.indexOf(m) === -1;
        });
        return yield* this.save();
    };



    Record.prototype.save = function*() {
        var extensionsService = services.get('extensionsService');
        var model = extensionsService.getModuleByName("record", this.type, this.version, "model");

        var typeParts = this.type.split('/');
        this.recordType = typeParts[1];
        this.version = typeParts[2];
        var versionParts = this.version.split('.');
        this.versionMajor = parseInt(versionParts[0]);
        this.versionMinor = parseInt(versionParts[1]);
        this.versionRevision = parseInt(versionParts[2]);

        //if stub is a reserved name, change it
        var conf = services.get('configuration');
        if (this.stub) {
            if (conf.reservedNames.indexOf(this.stub) > -1)
                throw new Error("Stub cannot be " + this.stub + ", it is reserved");

            var regex = /[a-z][a-z0-9|-]*/;
            if (!regex.test(this.stub))
                throw new Error("Stub is invalid");
        } else {
            this.stub = this.stub || randomizer.uniqueId(16);
        }

        var result = yield* RecordBase.prototype.save.call(this);

        if (this.state === 'published') {
            _ = yield* models.App.findById(this.appId);
        }
        
        return result;
    };



    Record.prototype.getCreator = function*() {
        return yield* models.User.findById(this.createdBy.id);
    };



    exports.Record = Record;

})();
