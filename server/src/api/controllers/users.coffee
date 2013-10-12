https = require 'https'
conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../common/utils')
controller = require('./controller')
Q = require('../../common/q')

class Users extends controller.Controller
    
    create: (req, res, next) =>
        switch req.body.credentials_type
            when 'builtin'
                @createBuiltinUser req, res, next
            when 'twitter'
                @createTwitterUser req, res, next



    createBuiltinUser: (req, res, next) =>
        if req.body.secret is conf.auth.adminkeys.default
            req.body.createdVia = 'internal' 
            (Q.async =>
                try                    
                    result = yield models.User.create(req.body, { type: 'builtin', value: { password: req.body.credentials_password } }, { user: req.user }, db)
                    res.contentType 'json'
                    res.send { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token }
                catch e
                    next e)()
        else
            next new Error 'Access denied'
        


    createTwitterUser: (req, res, next) =>
        (Q.async =>
            try
                result = yield models.User.create(
                    req.body, 
                    { 
                        type: 'twitter', 
                        value: { 
                            id: req.body.credentials_id, 
                            username: req.body.credentials_username,    
                            accessToken: req.body.credentials_accessToken, 
                            accessTokenSecret: req.body.credentials_accessTokenSecret 
                        } 
                    }, 
                    { user: req.user }, 
                    db
                )
                res.contentType 'json'
                res.send { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token }
            catch e
                next e)()



    item: (req, res, next) =>
        (Q.async =>
            user = yield models.User.get { username: req.params.username }, {}, db
            if user
                res.send user.summarize()
            else
                res.send ''
        )()



exports.Users = Users
