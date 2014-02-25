co = require 'co'
hasher = require('../../lib/hasher')
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
auth = require '../../common/web/auth'
    
exports.create = auth.handler ->*
    type = yield @parser.body('type')

    credential = new models.Credential {                    
        email: '',                    
        preferences: { canEmail: true },
    }    
    
    switch type
        when 'builtin'
            if (yield @parser.body 'secret') is conf.auth.adminkeys.default
                username = yield @parser.body 'username'
                hashed = yield thunkify(hasher) { plaintext: yield @parser.body 'secret' }
                credential.builtin = {
                    method: 'PBKDF2',
                    username,
                    salt: hashed.salt.toString('hex'),
                    hash: hashed.key.toString('hex')
                }

        when 'twitter'
            credential.twitter = {
                id: yield @parser.body('id'), 
                username: yield @parser.body('username'),    
                accessToken: yield @parser.body('accessToken'), 
                accessTokenSecret: yield @parser.body('accessTokenSecret')
            
            }

    credential = yield credential.save {}, db
    @body = { id: @credential._id }

