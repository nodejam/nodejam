https = require 'https'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError
controller = require('../controller')
Q = require('../../../common/q')

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
                    res.send { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token, assetPath: result.user.assetPath }
                catch e
                    next e)()
        else
            next new AppError 'Access denied', 'ACCESS_DENIED'
        


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
                res.send { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token, assetPath: result.user.assetPath }
            catch e
                next e)()



    item: (req, res, next) =>
        (Q.async =>
            user = yield models.User.get { username: req.query.username }, {}, db
            if user
                res.send user.summarize()
            else
                res.send ''
        )()
        


    selectUsername: (req, res, next) =>
        (Q.async =>
            token = yield models.Token.get({ key: req.query.token }, {}, db)     
            token.value.userDetails.username = req.body.username
            token.value.userDetails.name = req.body.name
            token.value.userDetails.email = req.body.email
            result = yield models.User.create(token.value.userDetails, token.value.credentials, {}, db)
            if result.success
                res.clearCookie "twitter_oauth_process_key"
                res.cookie "userid", result.user._id.toString()
                res.cookie "username", result.user.username
                res.cookie "fullName", result.user.name
                res.cookie "token", result.token
                res.redirect "/"
            else
                next new AppError "Could not save user.", "SOME_ERROR"
            token.destroy {}, db)()


exports.Users = Users
