(function() {

    "use strict";

    var _;

    var services = require("fora-lib-services"),
        models = require('fora-lib-models');

    var typesService = services.getTypesService();

    module.exports = models.App.extend({

        my_init: function() {
            if (!this.cache)
                this.cache = { records: [] };
            if (!this.settings)
                this.settings = {};
        },

        my_createRecord: function*(request) {
            var record = yield this.createRecordViaRequest(request);
            this.cache.records.push(yield record.my_getCacheItem());
            yield this.save();
            return record;
        },


        my_editRecord: function*(stub, request) {
            var record = yield this.editRecordViaRequest(stub, request);
            this.cache.records = this.cache.records.filter(function(rec) { return rec.stub !== record.stub; });
            this.cache.records.push(yield record.my_getCacheItem());
            yield this.save();
            return record;
        },


        my_deleteRecord: function*(stub, request) {
            var record = yield this.deleteRecordViaRequest(request);
            this.cache.records = this.cache.records.filter(function(rec) { return rec.stub !== record.stub; });
            yield this.save();
            return record;
        },


        my_addRecordMeta: function*(stub, request) {
            var record = yield this.addRecordMetaViaRequest(stub, request);
            this.cache.records = this.cache.records.filter(function(rec) { return rec.stub !== record.stub; });
            this.cache.records.push(yield record.my_getCacheItem());
            yield this.save();
            return record;
        }

    });
})();
