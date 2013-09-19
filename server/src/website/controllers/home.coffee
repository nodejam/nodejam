controller = require('./controller')
conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../common/utils')
Q = require('../../common/q')


class Home extends controller.Controller

    constructor: ->
    
    
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    editorsPicks = yield models.Post.find({ meta: 'pick', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db)
                    for post in editorsPicks
                        post.summary = post.getView("card")
                        post.summary.view = "wide"

                    featured = yield models.Post.find({ meta: 'featured', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
                    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)
                    for post in featured
                        post.summary = post.getView("card")
                        post.summary.view = "standard"

                    res.render req.network.getView('home', 'index'), { 
                        editorsPicks, 
                        featured, 
                        pageName: 'home-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
                            


    login: (req, res, next) =>
        res.render req.network.getView('home', 'login'), { 
            pageName: 'login-page', 
            pageType: 'std-page', 
        }



exports.Home = Home
