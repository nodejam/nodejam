co = require 'co'
thunkify = require 'thunkify'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
auth = require '../../lib/web/auth'
    
exports.create = auth.handler ->*

    if (yield @parser.body 'secret') is conf.auth.adminkeys.default    
        type = yield @parser.body('type')

        credential = new models.Credential {                    
            email: yield @parser.body('email'),
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
                
        session = yield credential.createSession {}, db
        @body = { token: session.token }

