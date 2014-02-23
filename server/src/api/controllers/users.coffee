shttps = require 'https'
co = require 'co'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'
    
exports.create = auth.handler ->*
    cred_type = yield @parser.body('credentials_type')
    switch cred_type
        when 'builtin'
            if (yield @parser.body 'secret') is conf.auth.adminkeys.default
                user = new models.User {
                    username: yield @parser.body 'username'            
                    preferences: { canEmail: true },
                    createdVia: 'internal'
                }                
                yield updateUser user, @parser
                
                authInfo = { type: 'builtin', value: { password: yield @parser.body('credentials_password') } }
                result = yield user.create authInfo, { user: @session?.user }, db    
                @body = { userId: result.user._id, username: result.user.username, name: result.user.name, token: result.token }

        when 'twitter'
            user = new models.User {
                username: yield @parser.body 'username'            
            }
            yield updateUser user, @parser

            authInfo = { 
                type: 'twitter', 
                value: { 
                    id: yield @parser.body('credentials_id'), 
                    username: yield @parser.body('credentials_username'),    
                    accessToken: yield @parser.body('credentials_accessToken'), 
                    accessTokenSecret: yield @parser.body('credentials_accessTokenSecret')
                } 
            }
            result = yield user.create authInfo, { user: @parser.user }, db
            @body = { userId: result.user._id, username: result.user.username, name: result.user.name, token: result.token }
    
    

updateUser = (user, parser) ->*
    user.name = yield parser.body('name')
    user.location = yield parser.body('location')
    user.email = yield parser.body('email') ? 'unknown@foraproject.org'
    user.lastLogin = Date.now()
    user.about = yield parser.body('about')
    


exports.item = auth.handler ->*
    user = yield models.User.get { username: @parser.params('username') }, {}, db
    if user
        res.send user.summarize()
    else
        res.send ''

