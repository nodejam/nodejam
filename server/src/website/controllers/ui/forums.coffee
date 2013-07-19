controller = require '../controller'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError

class Forums extends controller.Controller

    constructor: ->

    
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            models.Forum.find { network: req.network.stub }, ((cursor) -> cursor.sort({ lastPost: -1 }).limit 12), {}, db, (err, featured) =>
                for forum in featured
                    forum.summary = forum.getView("card")
                    forum.summary.view = "standard"
                
                res.render 'forums/index.hbs', { 
                    featured, 
                    pageName: 'forums-page', 
                    pageType: 'cover-page', 
                    cover: '/pub/images/cover.jpg'
                }
            
    
    
    forum: (req, res, next) =>
        @attachUser arguments, =>
            models.Forum.get { stub: req.params.forum, network: req.network.stub }, {}, db, (err, forum) =>
                models.Post.find { 'forum.stub': req.params.forum, 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db, (err, posts) =>
                    for post in posts
                            post.summary = post.getView("card")
                            post.summary.view = "standard"

                    res.render 'forums/forum.hbs', { 
                        forum,
                        posts, 
                        pageName: 'forum-page', 
                        pageType: 'cover-page', 
                        cover: @cover ? '/pub/images/cover.jpg'
                    }


exports.Forums = Forums
