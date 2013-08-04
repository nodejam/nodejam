conf = require '../../../conf'
database = (require '../../../common/database').Database
db = new database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller
controllers = require './'


class Forums extends Controller

    index: (req, res, next) =>
        @attachUser arguments, =>
            models.Forum.find({ network: req.network.stub }, ((cursor) -> cursor.sort({ lastPost: -1 }).limit 12), {}, db)
                .then (featured) =>
                    for forum in featured
                        forum.summary = forum.getView("card")
                        forum.summary.view = "standard"
                    
                    res.render req.network.views.forums.index, { 
                        featured, 
                        pageName: 'forums-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
            
    
    
    item: (req, res, next) =>
        @attachUser arguments, =>
            models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                .then (forum) =>
                    models.Post.find({ 'forum.stub': req.params.forum, 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
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
    
    
    
    post: (req, res, next) =>
        @attachUser arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.item
        


    invokeTypeSpecificController: (req, res, next, getHandler) =>   
        models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
            .then (forum) =>
                models.Post.get({ 'forum.id': forum._id.toString(), stub: (req.params.stub) }, {}, db)
                    .then (post) =>
                        models.User.getById(post.createdBy.id, {}, db)
                            .then (user) =>
                                getHandler(@getTypeSpecificController(post.type)) req, res, next, post, user, forum



    getTypeSpecificController: (type) =>
        switch type
            when 'article'
                return new controllers.Articles()        


exports.Forums = Forums
