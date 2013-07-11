conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller

class Articles extends Controller
            
    create: (req, res, next, forum) =>
        article = new models.Article
        article.createdBy = req.user
        article.forum = forum.summarize()
        article.rating = 0
        
        if req.body.publish is 'true'        
            article.publishedAt = Date.now()
            article.state = 'published'
        else
            article.state = 'draft'
        
        @parseBody article, req.body
        
        article.save { user: req.user }, db, (err, article) =>
            if not err
                res.send article
                        
                if req.body.publish is 'true'
                    message = new models.Message {
                        userid: '0',
                        type: "global-notification",
                        reason: 'published-article',
                        related: [ { type: 'user', id: req.user.id }, { type: 'forum', id: forum.stub } ],
                        data: { article }
                    }
                    message.save {}, db, (err, msg) =>  
            else
                next err
            
                                

    edit: (req, res, next, forum) =>
        _handleError = @handleError next  
        models.Article.getById req.params.post, {}, db, (err, article) =>
            if not err
                if article
                    if article.createdBy.id is req.user.id or @isAdmin(req.user)
                        alreadyPublished = article.state is 'published'

                        if not alreadyPublished and req.body.publish is 'true'
                            article.publishedAt ?= Date.now()
                            article.state = 'published'

                        @parseBody article, req.body
                             
                        article.save { user: req.user }, db, _handleError (err, article) =>
                            if not err
                                if article.createdBy.id is req.user.id and not alreadyPublished and req.body.publish is 'true'
                                    message = new models.Message {
                                        userid: '0',
                                        type: "global-notification",
                                        reason: 'published-article',
                                        related: [ { type: 'user', id: req.user.id }, { type: 'forum', id: forum.stub } ],
                                        data: { article }
                                    }
                                    message.save {}, db, (err, msg) =>  
                    else
                        res.send 'Access denied.'
                else
                    res.send 'Invalid article.'
            else
                next err                    
    


    remove: (req, res, next, forum) =>
        models.Article.getById req.params.post, {}, db, (err, article) =>
            if not err
                if article
                    if article.createdBy.id is req.user.id or @isAdmin(req.user)
                        article.destroy {}, db, (err, article) => 
                            res.send article
                    else
                        res.send 'Access denied.'
                else
                    res.send "Invalid article."
            else
                next err        
        
        
    
    addComment: (req, res, next, forum) =>        
        contentType = forum.settings?.comments?.contentType ? 'text'
        if contentType is 'text'
            models.Article.getById req.params.post, {}, db, (err, article) =>
                comment = new models.Comment()
                comment.createdBy = req.user
                comment.forum = forum.stub
                comment.itemid = article._id.toString()
                comment.data = req.body.data
                comment.save {}, db, (err, comment)=>
                    res.send comment
                
        else
            next new AppError 'Unsupported Comment Type', 'UNSUPPORTED_COMMENT_TYPE'
        

    parseBody: (article, body) =>
        article.format = 'markdown'

        if body.stub
            article.stub = body.stub.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')

        if body.title
            article.title = body.title

        if body.content
            article.content = body.content

        if body.cover
            article.cover = body.cover
            if body.coverTitle
                article.coverTitle = body.coverTitle
            article.smallCover = body.smallCover
    
exports.Articles = Articles
