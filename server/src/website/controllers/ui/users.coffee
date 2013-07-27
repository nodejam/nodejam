conf = require '../../../conf'
database = (require '../../../common/database').Database
db = new database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller
controllers = require './'


class Users extends Controller

    constructor: ->


    
    item: (req, res, next) =>
        @attachUser arguments, =>
            models.Forum.find { 'createdBy.username': req.params.id, network: req.network.stub }, ((cursor) -> cursor.sort({ lastPost: -1 }).limit 12), {}, db, (err, featured) =>
                for forum in featured
                    forum.summary = forum.getView("card")
                    forum.summary.view = "standard"
                
                res.render req.network.views.forums.index, { 
                    featured, 
                    pageName: 'forums-page', 
                    pageType: 'cover-page', 
                    cover: '/pub/images/cover.jpg'
                }



exports.Users = Users
