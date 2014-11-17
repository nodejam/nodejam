(function() {
    "use strict";

    var _;

    var recordCommon = require('./record-common'),
        randomizer = require('fora-app-randomizer'),
        dataUtils = require('fora-data-utils'),
        services = require('fora-app-services'),
        DbConnector = require('fora-app-db-connector'),
        models = require('./');


    var Record = function(params) {
        dataUtils.extend(this, params);
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        if (this.my_init)
            this.my_init();
    };

    recordCommon.extendRecord(Record);

    var recordStore = new DbConnector(Record);

    Record.search = function*(criteria, settings) {
        var limit = getLimit(settings.limit, 100, 1000);

        var params = {};
        for (var k in criteria) {
            v = criteria[k];
            params[k] = v;
        }

        return yield* recordStore.find(params, { sort: settings.sort, limit: limit });
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



    Record.prototype.addMeta = function*(metaList) {
        metaList.forEach(function(m) {
            if (this.meta.indexOf(m) === -1)
                this.meta.push(m);
        }, this);
        return yield* recordStore.save(this);
    };



    Record.prototype.removeMeta = function*(metaList) {
        this.meta = this.meta.filter(function(m) {
            return metaList.indexOf(m) === -1;
        });
        return yield* recordStore.save(this);
    };



    Record.prototype.save = function*() {
        var extensionsService = services.get('extensionsService');
        var model = extensionsService.getModule("record", this.type, this.version, "model");

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
        return yield* recordStore.save(this);
    };



    Record.prototype.getCreator = function*() {
        var userStore = new DbConnector(models.User);
        return yield* userStore.findById(this.createdBy.id);
    };


    exports.Record = Record;

})();
