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
                                
exports.Users = Users
