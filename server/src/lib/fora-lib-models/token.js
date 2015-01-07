(function() {
    "use strict";

    var dataUtils = require('fora-data-utils');

    var Token = function(params) {
        dataUtils.extend(this, params);
    };

    Token.entitySchema = {
        name: "token",
        collection: 'tokens',
        schema: {
            type: 'object',
            properties: {
                type: { type: 'string' },
                key: { type: 'string' },
                value: { type: 'object' },
            },
            required: ['type', 'key', 'value']
        },
        indexes: [{ 'key': 1 }, { 'key': 1, 'type': 1 }]
    };

    exports.Token = Token;

})();
