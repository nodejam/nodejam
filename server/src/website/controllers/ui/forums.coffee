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
            
            res.render 'forums/index.hbs', { 
                editorsChoices, 
                featured, 
                pageName: 'home-page', 
                pageType: 'cover-page', 
                cover: 'http://blogs-images.forbes.com/singularity/files/2013/01/Aaron_Swartz.jpg'
            }


exports.Forums = Forums
