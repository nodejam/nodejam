conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../lib/utils')
Q = require '../../lib/q'
Controller = require('../../common/web/controller').Controller


class Home extends Controller

    constructor: ->
    
    
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    editorsPicks = yield models.Post.find({ meta: 'pick', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db)
                    featured = yield models.Post.find({ meta: 'featured', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
                    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)

                    for post in editorsPicks.concat(featured)
                        template = post.getTemplate 'card'
                        post.html = template.render {
                            post,
                            forum: post.forum,
                        }

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
