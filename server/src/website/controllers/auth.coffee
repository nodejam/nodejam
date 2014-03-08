https = require 'https'
path = require 'path'
gm = require 'gm'
thunkify = require 'thunkify'
vOAuth = require('oauth').OAuth
fs = require 'fs-extra'
utils = require '../../lib/utils'
netutils = require '../../common/netutils'
fsutils = require '../../common/fsutils'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
auth = require '../../common/web/auth'


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


exports.twitter = ->*

    thunk_getOAuthRequestToken = ->
        (cb) ->
            oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
                cb error, { oauth_token, oauth_token_secret, results }

    { oauth_token, oauth_token_secret, results } = yield thunk_getOAuthRequestToken()
    oauthProcessKey = utils.uniqueId(24)
    oauth = { token: oauth_token, token_secret: oauth_token_secret }

    token = new models.Token {
        type: 'twitter-oauth-process-key',
        key: oauthProcessKey,
        value: oauth                    
    }        
    
    token = yield token.save {}, db
    @cookies.set 'twitter_oauth_process_key', oauthProcessKey
    @redirect "https://twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"
                    


exports.twitterCallback = ->*

    thunk_getOAuthAccessToken = (token, secret, verifier) ->
        (cb) ->
            oa.getOAuthAccessToken token, secret, verifier, (error, accessToken, accessTokenSecret, results) ->
                cb error, { accessToken, accessTokenSecret, results }

    thunk_oaGet = (url, token, secret) ->
        (cb) ->
            oa.get url, token, secret, (e, data) ->
                cb e, data    

    token = yield models.Token.get({ key: @cookies.get('twitter_oauth_process_key') }, {}, db)

    if token
        oauth = token.value
        oauth.verifier = @query.oauth_verifier
        { accessToken, accessTokenSecret, results } = yield thunk_getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier

        data = JSON.parse yield thunk_oaGet "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{results.screen_name}", accessToken, accessTokenSecret
        
        if data.length and data[0]?
            twitterUser = parseTwitterResponse data[0]                                                                    
            credential = yield models.Credential.get({ "twitter.id": results.user_id }, {}, db)        
            
            if not credential
                credential = new models.Credential()
                credential = yield credential.addTwitter twitterUser.id, twitterUser.username, token.value.token, token.value.token_secret, {}, db                

            userDetails = {
                username: twitterUser.username,
                name: twitterUser.name,
                picture: twitterUser.pictureUrl
            }
            
            _token = new models.Token {
                type: 'twitter-login-token',
                key: utils.uniqueId(24),
                value: { userDetails }
            }                                        
            _token = yield _token.save({}, db)
    
            @cookies.set 'twitter_oauth_process_key', ''
            @redirect "/users/login?token=#{_token.key}"
            
        else
            @body = "INVALID_TWITTER_RESPONSE"
                    
        yield token.destroy {}, db
                                            
    

parseTwitterResponse = (resp) ->
    {
        id: resp.id.toString(),
        username: resp.screen_name,
        name: resp.name ? resp.screen_name,
        location: resp.location ? '',
        email: "unknown@example.com",
        pictureUrl: resp.profile_image_url.replace '_normal', ''
    }
    
