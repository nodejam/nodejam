co = require 'co'
thunkify = require 'thunkify'
utils = require '../../lib/utils'
hasher = require '../../lib/hasher'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
auth = require '../../common/web/auth'
    
exports.create = auth.handler ->*
    if (yield @parser.body 'secret') is conf.auth.adminkeys.default
        type = yield @parser.body('type')

        credential = new models.Credential {                    
            email: 'unknown@4ah.org',                    
            preferences: { canEmail: true }
        }    
        
        switch type
            when 'builtin'
                username = yield @parser.body 'username'
                password = yield @parser.body 'password'                
                credential = yield credential.addBuiltin username, password, {}, db

            when 'twitter'
                id = yield @parser.body 'id'
                username = yield @parser.body 'username'
                accessToken = yield @parser.body 'accessToken'
                accessTokenSecret = yield @parser.body 'accessTokenSecret'
                credential = yield credential.addTwitter id, username, accessToken, accessTokenSecret, {}, db

        @body = { id: credential._id, token: credential.token }

