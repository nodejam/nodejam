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
models = require '../../models'
db = new (require '../../lib/data/database').Database(conf.db)
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



thunk_getOAuthRequestToken = ->
    (cb) ->
        oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
            cb error, { oauth_token, oauth_token_secret, results }

exports.twitter = ->*
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
                    


thunk_getOAuthAccessToken = (token, secret, verifier) ->
    (cb) ->
        oa.getOAuthAccessToken token, secret, verifier, (error, accessToken, accessTokenSecret, results) ->
            cb error, { accessToken, accessTokenSecret, results }

thunk_oaGet = (url, token, secret) ->
    (cb) ->
        oa.get url, token, secret, (e, data) ->
            cb e, data    
            
exports.twitterCallback = ->*
    token = yield models.Token.get({ key: @cookies.get('twitter_oauth_process_key') }, {}, db)
    if token
        oauth = token.value
        oauth.verifier = @query.oauth_verifier
        { accessToken, accessTokenSecret, results } = yield thunk_getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier

        credentials = yield models.Credentials.get({ "twitter.id": results.user_id }, {}, db)        
        data = JSON.parse yield thunk_oaGet "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{results.screen_name}", accessToken, accessTokenSecret

        if credentials
            user = yield credentials.getUser {}, db
            if data.length and data[0]?
                fileName = path.join "#{user.assets}", user.username
                filePath = yield netutils.downloadImage (parseTwitterUserDetails data[0]).pictureUrl

                picPath = fsutils.getFilePath 'assets', "#{user.assets}/#{user.username}.jpg"
                thumbPath = fsutils.getFilePath 'assets', "#{user.assets}/#{user.username}_t.jpg"
                
                utils.log "Resizing to " + picPath                
                
                gmagick = gm(filePath).resize(128, 128)
                yield thunkify(gmagick.write).call gmagick, picPath
                fs.copy picPath, thumbPath
                
                @cookies.set "userid", user._id.toString(), { httpOnly: false }
                @cookies.set "username", user.username, { httpOnly: false }
                @cookies.set "fullName", user.name, { httpOnly: false }
                @cookies.set "token", credentials.token
                @redirect "/"                                                
        else
            if data.length and data[0]?
                userDetails = parseTwitterUserDetails data[0]                                                    
                credentials = { 
                    type: 'twitter', 
                    value: { id: userDetails.id, username: userDetails.username, accessToken: token.value.token, accessTokenSecret: token.value.token_secret }
                }
                _token = new models.Token {
                    type: 'twitter-tokens',
                    key: utils.uniqueId(24),
                    value: { userDetails, credentials }
                }                                        
                _token = yield _token.save({}, db)
                @redirect "/users/selectusername?token=#{_token.key}"
            else
                this.body = "INVALID_TWITTER_RESPONSE"                            
            
            token.destroy {}, db


parseTwitterUserDetails = (userDetails) ->
    {
        id: userDetails.id.toString(),
        username: userDetails.screen_name,
        name: userDetails.name ? userDetails.screen_name,
        location: userDetails.location ? '',
        email: "unknown@example.com",
        pictureUrl: userDetails.profile_image_url.replace '_normal', ''
    }
    
