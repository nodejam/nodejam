controller = require('../controller')
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError

class Home extends controller.Controller

    constructor: ->
    
    
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            models.Post.find { meta: 'pick', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db, (err, editorsPicks) =>

                for post in editorsPicks
                    post.summary = post.getView("card")
                    post.summary.view = "wide"

                models.Post.find { meta: 'featured', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db, (err, featured) =>    

                    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)

                    for post in featured
                        post.summary = post.getView("card")
                        post.summary.view = "standard"

                    res.render req.network.views.home.index, { 
                        editorsPicks, 
                        featured, 
                        pageName: 'home-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }


    login: (req, res, next) =>
        res.render req.network.views.home.login, { 
            pageName: 'login-page', 
            pageType: 'std-page', 
        }



exports.Home = Home
