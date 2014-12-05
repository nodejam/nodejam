(function() {

    "use strict";

    var dataUtils = require('fora-data-utils');
    
    var UserInfo = function(params) {
        dataUtils.extend(this, params);
        if (!this.subscriptions)
            this.subscriptions = [];

        if (!this.following)
            this.following = [];
    };


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
