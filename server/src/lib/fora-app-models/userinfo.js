(function() {
    "use strict";

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var ForaDbModel = require('./foramodel').ForaDbModel;

    var UserInfo = function() {
        ForaDbModel.apply(this, arguments);

        if (!this.subscriptions)
            this.subscriptions = [];

        if (!this.following)
            this.following = [];

    };

    UserInfo.prototype = Object.create(ForaDbModel.prototype);
    UserInfo.prototype.constructor = UserInfo;

    __extends(UserInfo, ForaDbModel);


    UserInfo.typeDefinition = {
        name: "user-info",
        collection: 'userinfo',
        schema: {
            type: 'object',
            properties: {
                userId: { type: 'string' },
                subscriptions: { type: 'array', items: { $ref: 'app-summary' } },
                following: { type: 'array', items: { $ref: 'user-summary' } },
                lastMessageAccessTime: { type: 'number' }
            },
            required: ['userId', 'following', 'subscriptions' ]
        },
        links: {
            user: { type: 'user', key: 'userId' }
        },
        logging: {
            onInsert: 'NEW_USER'
        }
    };

    exports.UserInfo = UserInfo;
})();
