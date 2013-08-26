controller = require '../controller'
conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError

class Articles extends controller.Controller

    item: (req, res, next, article, user, forum) =>
        article.formattedContent = article.formatContent()        
        res.render req.network.getView('articles', 'item'), { 
            article,
            user,
            forum,
            pageName: 'article-page', 
            pageType: 'std-page', 
        }
                
    
    
    
exports.Articles = Articles
