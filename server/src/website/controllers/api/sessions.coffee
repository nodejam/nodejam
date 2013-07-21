https = require 'https'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError
controller = require('../controller')

class Sessions extends controller.Controller
    
    create: (req, res, next) =>
        if req.body.domain is 'fb'        
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
                if _userDetails.domainid and _userDetails.name
                    models.User.getOrCreateUser _userDetails, 'fb', req.body.accessToken, {}, db, (err, user, session) =>
                        if not err
                            res.contentType 'json'
                            res.send { 
                                userid: user._id, 
                                domain: 'fb', 
                                username: user.username, 
                                name: user.name, 
                                passkey: session.passkey
                            }
                        else
                            next err
                else
                    next new AppError 'Invalid credentials', 'INVALID_CREDENTIALS'
                    
                    
        else if req.body.domain is 'users'
            if req.body.secret is conf.auth.adminkeys.default
                accessToken = utils.uniqueId(24)
                req.body.createdVia = 'internal' 
                models.User.getOrCreateUser req.body, 'users', accessToken, {}, db, (err, user, session) =>
                    if not err
                        res.contentType 'json'
                        res.send { userid: user._id, domain: 'users', username: user.username, name: user.name, passkey: session.passkey }
                    else
                        next err
            else
                next new AppError 'Access denied', 'ACCESS_DENIED'
    
    
            

exports.Sessions = Sessions
