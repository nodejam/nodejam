(function() {
    "use strict";

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var ForaDbModel = require('./foramodel').ForaDbModel;

    var Token = function() {
        ForaDbModel.apply(this, arguments);
    };

    Token.prototype = Object.create(ForaDbModel.prototype);
    Token.prototype.constructor = Token;

    __extends(Token, ForaDbModel);

    Token.typeDefinition = {
        name: "token",
        collection: 'tokens',
        schema: {
            type: 'object',
            properties: {
                type: { type: 'string' },
                key: { type: 'string' },
                value: {
                    type: 'object'
                },
            },
            required: ['type', 'key', 'value']
        },
        indexes: [{ 'key': 1 }],
    };


    exports.Token = Token;
})();
