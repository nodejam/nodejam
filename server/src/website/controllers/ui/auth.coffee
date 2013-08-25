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
                            #See if we already have a user for this twitter user
                            models.Credentials.get({ "twitter.id": results.user_id }, {}, db)
                                .then (credentials) =>
                                    if credentials
                                        credentials.getUser({}, db)
                                            .then (user) =>
                                                res.cookie "userid", user._id.toString()
                                                res.cookie "username", user.username
                                                res.cookie "fullName", user.name
                                                res.cookie "assetPath", user.assetPath
                                                res.cookie "token", credentials.token
                                                res.redirect "/"
                                    else
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
                                                            res.redirect "/users/selectusername?token=#{_token.key}"

                                                    token.destroy {}, db #We don't need this token anymore.
                                                else
                                                    utils.log JSON.stringify data
                                                    res.send "Invalid response."                            
                                                    token.destroy {}, db #We don't need this token anymore.

                                    
                else
                    utils.log "No token"
                    res.send "Could not connect to Twitter."


    
    parseTwitterUserDetails: (userDetails) =>
        {
            id: userDetails.id.toString(),
            username: userDetails.screen_name,
            name: userDetails.name ? userDetails.screen_name,
            location: userDetails.location ? '',
            email: "twitteruser@poe3.com",
            picture: userDetails.profile_image_url,
            thumbnail: userDetails.profile_image_url
        }                
            

exports.Auth = Auth
