conf = require '../../../conf'
database = (require '../../../common/database').Database
db = new database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller
controllers = require './'
Q = require('../../../common/q')


class Forums extends Controller

    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    featured = yield models.Forum.find({ network: req.network.stub }, ((cursor) -> cursor.sort({ lastPost: -1 }).limit 12), {}, db)
                    for forum in featured
                        forum.summary = forum.getView("card")
                        forum.summary.view = "standard"
                    
                    res.render req.network.getView('forums', 'index'), { 
                        featured, 
                        pageName: 'forums-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
            
    
    
    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                    post = yield models.Post.find({ 'forum.stub': req.params.forum, 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
                    for post in posts
                            post.summary = post.getView("card")
                            post.summary.view = "standard"

                    res.render req.network.getView('forums', 'item'), { 
                        forum,
                        posts, 
                        pageName: 'forum-page', 
                        pageType: 'cover-page', 
                        cover: @cover ? '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()

    
    
    post: (req, res, next) =>
        @attachUser arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.item
        


    invokeTypeSpecificController: (req, res, next, getHandler) =>   
        (Q.async =>
            try
                forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                post = yield models.Post.get({ 'forum.id': forum._id.toString(), stub: (req.params.stub) }, {}, db)
                user = yield models.User.getById(post.createdBy.id, {}, db)
                getHandler(@getTypeSpecificController(post.type)) req, res, next, post, user, forum
            catch e
                next e)()



    getTypeSpecificController: (type) =>
        switch type
            when 'article'
                return new controllers.Articles()        


exports.Forums = Forums
