conf = require '../../../conf'
database = (require '../../../common/database').Database
db = new database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller
controllers = require './'
Q = require('../../../common/q')


class Users extends Controller

    selectUsernameForm: (req, res, next) =>
        (Q.async =>
            token = yield models.Token.get({ key: req.query.token }, {}, db)
            res.render req.network.views.users.selectusername, { 
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
                res.cookie "assetPath", result.user.assetPath
                res.cookie "token", result.token
                res.redirect "/"
            else
                next new AppError "Could not save user.", "SOME_ERROR"
            token.destroy {}, db)()        
                                
exports.Users = Users
