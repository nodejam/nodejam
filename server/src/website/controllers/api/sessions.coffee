https = require 'https'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError
controller = require('../controller')

class Sessions extends controller.Controller
    
    create: (req, res, next) =>
        if req.body.credentialType is 'facebook'        
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
                _userDetails = @parseFBUserDetails(JSON.parse userDetails)
                if _userDetails.name
                    models.User.getOrCreateUser _userDetails, {}, db, (err, user, session) =>
                        if not err
                            res.contentType 'json'
                            res.send { 
                                userid: user._id, 
                                username: user.username, 
                                name: user.name, 
                                passkey: session.passkey
                            }
                        else
                            next err
                else
                    next new AppError 'Invalid credentials', 'INVALID_CREDENTIALS'
                    
                    
        else if req.body.credentialType is 'builtin'
            if req.body.secret is conf.auth.adminkeys.default
                req.body.createdVia = 'internal' 
                models.User.getOrCreateUser req.body, {}, db, (err, user, session) =>
                    if not err
                        res.contentType 'json'
                        res.send { userid: user._id, username: user.username, name: user.name, passkey: session.passkey }
                    else
                        next err
            else
                next new AppError 'Access denied', 'ACCESS_DENIED'
    


    parseFBUserDetails: (userDetails) =>
        {
            username: userDetails.username ? userDetails.id,
            name: userDetails.name,
            location: userDetails.location,
            email: userDetails.email,
            picture: "http://graph.facebook.com/#{userDetails.id}/picture?type=large",
            thumbnail: "http://graph.facebook.com/#{userDetails.id}/picture"
        }
    
            

exports.Sessions = Sessions
