https = require 'https'

controller = require('../controller')
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError

OAuth = require('oauth').OAuth


class Auth extends controller.Controller
    
    twitter: (req, res, text) =>
        oa = new OAuth(
	        "https://api.twitter.com/oauth/request_token",
	        "https://api.twitter.com/oauth/access_token",
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_CONSUMER_KEY,
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_SECRET,
	        "1.0",
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_CALLBACK,	
	        "HMAC-SHA1"
        )
        
        oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
            if error
                utils.log error
                res.send "Error in authenticating"
            else
                oauthProcessKey = utils.uniqueId(24)
                oauth = { token: oauth_token, token_secret: oauth_token_secret }

                token = new models.Token {
                    network: req.network.stub,
                    type: 'oauth-process-key',
                    key: oauthProcessKey,
                    value: oauth                    
                }        
    
                token.save { user: req.user }, (err, token) =>
                    if not err
                        res.cookie 'oauth_process_key', oauthProcessKey
                        res.send "
                            <html>
                                <script type=\"text/javascript\">
                                    window.location.href = \"https://twitter.com/oauth/authenticate?oauth_token=#{oauth_token}\";
                                </script>
                                <body></body>
                            </html>"
                    else
                        next err
            

    
    twitterCallback: (req, res, next) =>
        oa = new OAuth(
	        "https://api.twitter.com/oauth/request_token",
	        "https://api.twitter.com/oauth/access_token",
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_CONSUMER_KEY,
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_SECRET,
	        "1.0",
	        conf.authenticationTypes[req.network.stub].twitter.TWITTER_CALLBACK,	
	        "HMAC-SHA1"
        )
        models.Token.get { type: 'oauth-process-key', key: req.cookies.oauth_process_key, network: req.network.stub }, {}, (err, token) =>            
            if not err
                if token
                    oauth = token.value
                    oauth.verifier = req.query.oauth_verifier
                    oa.getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier, (error, accessToken, accessTokenSecret, results) =>
                        if error
	                        utils.log error
	                        res.send "Could not connect to Twitter."
                        else
                            utils.log "Twitter: authenticated #{results.screen_name}"
                            
                            response = ''                                    
                            https.get "https://api.twitter.com/1/users/lookup.json?screen_name=#{results.screen_name}", (_res) =>
                                _res.on 'data', (d) =>
                                    response += d                                    
                                _res.on 'end', =>
                                    resp = JSON.parse response
                                    if resp.length and resp[0]?
                                        userDetails = @parseTwitterUserDetails resp[0]
                                        models.User.getOrCreateUser userDetails, 'tw', req.network.stub, accessToken, (err, _user, _session) =>
                                            res.clearCookie "oauth_process_key"
                                            res.cookie "userid", _user._id.toString()
                                            res.cookie "domain", "tw"
                                            res.cookie "username", _user.username
                                            res.cookie "fullName", _user.name
                                            res.cookie "passkey", _session.passkey
                                            res.send '
                                                <html>
                                                    <script type="text/javascript">
                                                        window.location.href = "/";
                                                    </script>
                                                    <body></body>
                                                </html>'
                                                        
                                    else
                                        utils.log response
                                        res.send "Invalid response."                            
                else
                    utils.log "No token"
                    res.send "Could not connect to Twitter."
            else
                next err                
                


    parseTwitterUserDetails: (userDetails) =>
        {
            domainid: userDetails.id ? '',
            username: userDetails.screen_name,
            name: userDetails.name ? userDetails.screen_name,
            location: userDetails.location ? '',
            email: "twitteruser@poe3.com",
            picture: "https://api.twitter.com/1/users/profile_image?screen_name=#{userDetails.screen_name}&size=original",
            thumbnail: "https://api.twitter.com/1/users/profile_image?screen_name=#{userDetails.screen_name}&size=bigger",
            tile: '/images/collection-tile.png'
        }                
            

exports.Auth = Auth
