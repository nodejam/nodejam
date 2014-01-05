shttps = require 'https'
co = require 'co'
conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../lib/utils')
auth = require '../../common/web/auth'
    
exports.create = auth.handler ->*
    switch @parser.body('credentials_type')
        when 'builtin'
            if @parser.body('secret') is conf.auth.adminkeys.default
                user = new models.User {
                    username: @parser.body 'username'            
                    preferences: { canEmail: true },
                    createdVia: 'internal'
                }                
                
                updateUser user, @parser
                
                authInfo = { type: 'builtin', value: { password: @parser.body('credentials_password') } }
                result = yield user.create authInfo, { user: @session?.user }, db                
                @body = { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token }

        when 'twitter'
            user = new models.User {
                username: @parser.body 'username'            
            }
            updateUser user, @parser

            authInfo = { 
                type: 'twitter', 
                value: { 
                    id: @parser.body('credentials_id'), 
                    username: @parser.body('credentials_username'),    
                    accessToken: @parser.body('credentials_accessToken'), 
                    accessTokenSecret: @parser.body('credentials_accessTokenSecret')
                } 
            }
            result = yield user.create authInfo, { user: @parser.user }, db
            @body = { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token }
    
    

updateUser = (user, parser) ->
    user.name = parser.body('name')
    user.location = parser.body('location')
    user.email = parser.body('email') ? 'unknown@foraproject.org'
    user.lastLogin = Date.now()
    user.about = parser.body('about')
    


exports.item = auth.handler ->*
    user = yield models.User.get { username: @parser.params('username') }, {}, db
    if user
        res.send user.summarize()
    else
        res.send ''

