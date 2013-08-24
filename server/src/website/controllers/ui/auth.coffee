https = require 'https'
OAuth = require('oauth').OAuth
Q = require('../../../common/q')

utils = require '../../../common/utils'
conf = require '../../../conf'
models = require '../../../models'
db = new (require '../../../common/database').Database(conf.db)
AppError = require('../../../common/apperror').AppError
controller = require '../controller'

OAuth = require('oauth').OAuth
oa = new OAuth(
	"https://api.twitter.com/oauth/request_token",
	"https://api.twitter.com/oauth/access_token",
    conf.auth.twitter.TWITTER_CONSUMER_KEY,
    conf.auth.twitter.TWITTER_CONSUMER_SECRET,
	"1.0A",
	conf.auth.twitter.TWITTER_CALLBACK,	
	"HMAC-SHA1"
)

class Auth extends controller.Controller
    
    twitter: (req, res, text) =>
        oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
            if error
                utils.log error
                res.send "Error in authenticating"
            else
                oauthProcessKey = utils.uniqueId(24)
                oauth = { token: oauth_token, token_secret: oauth_token_secret }

                token = new models.Token {
                    type: 'twitter-oauth-process-key',
                    key: oauthProcessKey,
                    value: oauth                    
                }        
                
                (Q.async =>               
                    try
                        token = yield token.save {}, db
                        res.cookie 'twitter_oauth_process_key', oauthProcessKey
                        res.redirect "https://twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"
                    catch e
                        next e)()
                        

    
    twitterCallback: (req, res, next) =>
        models.Token.get({ key: req.cookies.twitter_oauth_process_key }, {}, db)
            .then (token) =>
                if token
                    oauth = token.value
                    oauth.verifier = req.query.oauth_verifier
                    oa.getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier, (error, accessToken, accessTokenSecret, results) =>
                        if error
                            utils.log error
                            res.send "Could not connect to Twitter."
                        else
                            utils.log "Twitter: authenticated #{results.screen_name}"
                            oa.get "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{results.screen_name}",
                                accessToken,
                                accessTokenSecret,
                                (e, data, _res) =>
                                    data = JSON.parse data
                                    if data.length and data[0]?
                                        userDetails = @parseTwitterUserDetails data[0]
                                        credentials = { 
                                            type: 'twitter', 
                                            value: { id: userDetails.id, username: userDetails.username, accessToken: token.value.token, accessTokenSecret: token.value.token_secret }
                                        }
                                        _token = new models.Token {
                                            type: 'twitter-tokens',
                                            key: utils.uniqueId(24),
                                            value: { userDetails, credentials }
                                        }                                        
                                        _token.save({}, db)
                                            .then (_token) =>
                                                res.redirect "/auth/selectusername?token=#{_token.key}"

                                        token.destroy {}, db #We don't need this token anymore.
                                    else
                                        utils.log JSON.stringify data
                                        res.send "Invalid response."                            
                                        token.destroy {}, db #We don't need this token anymore.

                                    
                else
                    utils.log "No token"
                    res.send "Could not connect to Twitter."

            

    selectUsernameForm: (req, res, next) =>
        (Q.async =>
            token = yield models.Token.get({ key: req.query.token }, {}, db)
            res.render req.network.views.auth.selectusername, { 
                username: token.value.userDetails.username,
                name: token.value.userDetails.name,
                pageName: 'select-username-page', 
                pageType: 'std-page', 
                token: token.key
            }
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
            

    
    parseTwitterUserDetails: (userDetails) =>
        {
            id: userDetails.id ? '',
            username: userDetails.screen_name,
            name: userDetails.name ? userDetails.screen_name,
            location: userDetails.location ? '',
            email: "twitteruser@poe3.com",
            picture: userDetails.profile_image_url,
            thumbnail: userDetails.profile_image_url
        }                
            

exports.Auth = Auth
