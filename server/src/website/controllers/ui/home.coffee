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
            models.Post.find { meta: 'featured' }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db, (err, posts) =>    
                for post in posts
                    post.summary = post.summarize("concise")
                res.render 'home/index.hbs', { posts }

exports.Home = Home
