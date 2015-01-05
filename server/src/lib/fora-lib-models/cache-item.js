(function() {

    "use strict";

    var dataUtils = require('fora-data-utils'),
    DbConnector = require('fora-lib-db-connector');

    var CacheItem = function(params) {
        dataUtils.extend(this, params);
    };

    CacheItem.typeDefinition = {
        name: "cache-item",
        collection: 'cacheitems',
        schema: {
            type: 'object',
            properties: {
                type: { type: 'string' },
                key: { type: 'string' },
                value: { type: 'object' },
                app: { type: 'string' }
            },
            required: ['type', 'key', 'value']
        },
        indexes: [{ 'key': 1 }, { 'key': 1, 'type': 1 }]
    };

    var cacheItemStore = new DbConnector(CacheItem);

    CacheItem.prototype.save = function*() {
        yield* cacheItemStore.save(this);
    };

    exports.CacheItem = CacheItem;

})();
