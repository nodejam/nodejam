conf = require '../../conf'
database = (require '../../common/data/database').Database
db = new database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Q = require('../../common/q')
Controller = require('../../fora/web/controller').Controller


class Users extends Controller

    selectUsernameForm: (req, res, next) =>
        (Q.async =>
            token = yield models.Token.get({ key: req.query('token') }, {}, db)
            res.render req.network.getView('users', 'selectusername'), { 
                username: token.value.userDetails.username,
                name: token.value.userDetails.name,
                pageName: 'select-username-page', 
                pageType: 'std-page', 
                token: token.key
            }
        )()
        
        

    selectUsername: (req, res, next) =>
        (Q.async =>
            token = yield models.Token.get({ key: req.query('token') }, {}, db)     
            token.value.userDetails.username = req.body 'username'
            token.value.userDetails.name = req.body 'name'
            token.value.userDetails.email = req.body 'email'
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
                
            token.destroy {}, db)()        
                                
exports.Users = Users
