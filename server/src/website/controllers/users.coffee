conf = require '../../conf'
database = (require '../../lib/data/database').Database
db = new database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'


exports.selectUsernameForm = ->*
    token = yield models.Token.get({ key: @query('token') }, {}, db)
    @render 'users/selectusername', { 
        username: token.value.userDetails.username,
        name: token.value.userDetails.name,
        pageName: 'select-username-page', 
        pageType: 'std-page', 
        token: token.key
    }
    
    

exports.selectUsername = ->*
    token = yield models.Token.get({ key: @query('token') }, {}, db)     
    token.value.userDetails.username = yield @parser.body 'username'
    token.value.userDetails.name = yield @parser.body 'name'
    token.value.userDetails.email = yield @parser.body 'email'
    result = yield models.User.create(token.value.userDetails, token.value.credentials, {}, db)
    if result?.success isnt false
        res.clearCookie "twitter_oauth_process_key"
        res.cookie "userid", result.user._id.toString()
        res.cookie "username", result.user.username
        res.cookie "fullName", result.user.name
        res.cookie "token", result.token
        res.redirect "/"
    else
        next new Error "Could not save user"
        
    token.destroy {}, db       
