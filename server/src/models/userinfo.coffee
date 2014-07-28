ForaDbModel = require('./foramodel').ForaDbModel

class UserInfo extends ForaDbModel

    @typeDefinition: {
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
        }
        logging: {
            onInsert: 'NEW_USER'
        }
    }

    
    constructor: (params) ->
        @subscriptions ?= []
        @following ?= []
        super
        


exports.UserInfo = UserInfo
