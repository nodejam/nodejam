(function() {

    "use strict";

    var _;

    var services = require("fora-app-services"),
        Parser = require('fora-request-parser'),
        models = require('fora-app-models');

    var typesService = services.get("typesService");

    module.exports = models.App.extend({

        init: function() {
            if (!this.cache)
                this.cache = { records: [] };
            if (!this.settings)
                this.settings = {};
        },

        createRecord: function*(request) {
            var record = yield* this.createRecordFromRequest(request);
            this.cache.records.push(record.getCacheItem());
            _ = yield* this.save();
            return record;
        }

    });

})();
