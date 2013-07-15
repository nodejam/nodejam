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
            models.Post.find { meta: 'pick' }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db, (err, editorsChoices) =>
                for post in editorsChoices
                    post.summary = post.summarize("concise")
                    post.summary.view = "wide"
                models.Post.find { meta: 'featured' }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db, (err, featured) =>    
                    featured = (f for f in featured when (x._id for x in editorsChoices).indexOf(f._id) is -1)
                    for post in featured
                        post.summary = post.summarize("concise")
                        post.summary.view = "standard"
                    res.render 'home/index.hbs', { editorsChoices, featured, pageName: 'home-page', pageType: 'cover-page', cover: 'http://blogs-images.forbes.com/singularity/files/2013/01/Aaron_Swartz.jpg' }

exports.Home = Home
