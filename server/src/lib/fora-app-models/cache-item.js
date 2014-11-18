(function() {

    "use strict";

    var dataUtils = require('fora-data-utils');

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

    exports.CacheItem = CacheItem;

})();
