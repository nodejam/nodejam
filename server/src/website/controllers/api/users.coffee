https = require 'https'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError
controller = require('../controller')

class Users extends controller.Controller
    
    create: (req, res, next) =>
        switch req.body.credentials_0_type
            when 'builtin'
                @createBuiltinUser req, res, next
            when 'twitter'
                @createTwitterUser req, res, next
            when 'facebook'
                @createFacebookUser req, res, next



    createBuiltinUser: (req, res, next) =>
        if req.body.secret is conf.auth.adminkeys.default
            req.body.createdVia = 'internal' 
            models.User.create(req.body, { type: 'builtin' }, {}, db)
                .then (result) =>
                    console.log 'got here...'
                    console.log JSON.stringify result
                    res.contentType 'json'
                    res.send { userid: result.user._id, username: result.user.username, name: result.user.name, token: result.token, assetPath: result.user.assetPath }
        else
            next new AppError 'Access denied', 'ACCESS_DENIED'
        
                    

    ###
    createFacebookUser: (req, res, next) =>
        if req.body.credentials_0_type is 'facebook'
            client = new FaceBookClient()            
            options = {
                path: '/me?' + querystring.stringify { 
                    fields: 'id,username,name,first_name,last_name,location,email', 
                    access_token: req.body.accessToken, 
                    client_id: conf.auth.facebook.FACEBOOK_APP_ID, 
                    client_secret: conf.auth.facebook.FACEBOOK_SECRET 
                }
            }
            
            client.secureGraphRequest options, (err, userDetails) =>
                _userDetails = {
                    username: userDetails.username ? userDetails.id,
                    name: userDetails.name,
                    location: userDetails.location,
                    email: userDetails.email,
                    picture: "http://graph.facebook.com/#{userDetails.id}/picture?type=large",
                    thumbnail: "http://graph.facebook.com/#{userDetails.id}/picture"
                }    
    ###

exports.Users = Users
