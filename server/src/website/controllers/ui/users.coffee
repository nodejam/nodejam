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
            models.Forum.find({ 'createdBy.username': req.params.id, network: req.network.stub }, ((cursor) -> cursor.sort({ lastPost: -1 }).limit 12), {}, db)
                .then (forums) =>
                    for forum in forums
                        models.Post.find({ 'forum.stub.id': forum.id, 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
                            .then (posts) =>
                                for post in posts
                                        post.summary = post.getView("card")
                                        post.summary.view = "standard"

                                res.render req.network.views.forums.item, { 
                                    forum,
                                    posts, 
                                    pageName: 'forum-page', 
                                    pageType: 'cover-page', 
                                    cover: @cover ? '/pub/images/cover.jpg'
                                    }
                                

                                
exports.Users = Users
