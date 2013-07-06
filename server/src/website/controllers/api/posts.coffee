conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
controller = require '../controller'

class Posts extends controller.Controller
            
    create: (req, res, next, forum) =>
        post = new models.Post
        post.network = req.network.stub
        post.createdBy = req.user
        post.forum = forum.summarize()
        post.rating = 0
        
        if req.body.publish is 'true'        
            post.publishedAt = Date.now()
            post.state = 'published'
        else
            post.state = 'draft'
        
        @parseBody post, req.body
        
        post.save { user: req.user }, (err, post) =>
            if not err
                item = new models.ItemView {
                    network: req.network.stub,
                    forum: post.forum.stub,
                    forumType: 'post',
                    itemid: post._id.toString(),                    
                    createdBy: post.createdBy,
                    createdAt: post.createdAt,
                    state: post.state,
                    type: 'post'
                    data: post.createView('summary')
                }
                
                if post.publishedAt
                    item.publishedAt = post.publishedAt
                
                item.save { user: req.user }, =>
                    res.send post
                        
                models.Post.refreshCollectionSnapshot post, {}, =>
                
                if req.body.publish is 'true'
                    message = new models.Message {
                        network: req.network.stub,
                        userid: '0',
                        type: "global-notification",
                        reason: 'published-post',
                        related: [ { type: 'user', id: req.user.id }, { type: 'forum', id: forum.stub } ],
                        data: { post }
                    }
                    message.save {}, (err, msg) =>  
            else
                next err
            
                                

    edit: (req, res, next, forum) =>
        _handleError = @handleError next  
        models.Post.get { uid: req.params.item, network: req.network.stub }, {}, (err, post) =>
            if not err
                if post
                    if post.createdBy.id is req.user.id or @isAdmin(req.user, req.network)
                        alreadyPublished = post.state is 'published'

                        if not alreadyPublished and req.body.publish is 'true'
                            post.publishedAt ?= Date.now()
                            post.state = 'published'

                        @parseBody post, req.body
                             
                        post.save { user: req.user }, _handleError (err, post) =>
                            if not err
                                #Remove from Item View
                                models.ItemView.get { type: "post", forum: post.forum, itemid: post.id.toString() }, {}, (err, item) =>
                                    item.data = post.createView('summary')   
                                    item.state = post.state

                                    if post.publishedAt
                                        item.publishedAt = post.publishedAt                                                 

                                    item.save { user: req.user }, =>
                                        res.send post
                                        
                                #Update stats on the forum
                                models.Post.refreshCollectionSnapshot post, {}, =>

                                if post.createdBy.id is req.user.id and not alreadyPublished and req.body.publish is 'true'
                                    message = new models.Message {
                                        network: req.network.stub,
                                        userid: '0',
                                        type: "global-notification",
                                        reason: 'published-post',
                                        related: [ { type: 'user', id: req.user.id }, { type: 'forum', id: forum.stub } ],
                                        data: { post }
                                    }
                                    message.save {}, (err, msg) =>  
                    else
                        res.send 'Access denied.'
                else
                    res.send 'Invalid post.'
            else
                next err                    
    


    remove: (req, res, next, forum) =>
        models.Post.get { uid: req.params.item, network: req.network.stub }, {}, (err, post) =>
            if not err
                if post
                    if post.createdBy.id is req.user.id or @isAdmin(req.user, req.network)
                        post.destroy {}, (err, post) => 
                            #Remove from Item View
                            models.ItemView.get { type: "post", forum: post.forum, itemid: post.id.toString() }, {}, (err, item) =>
                                item.destroy {}, =>

                            #Update stats on the forum
                            models.Post.refreshCollectionSnapshot post, {}, =>                               

                            res.send post
                    else
                        res.send 'Access denied.'
                else
                    res.send "Invalid post."
            else
                next err        
        
        
    
    addComment: (req, res, next, forum) =>        
        contentType = forum.settings?.comments?.contentType ? 'text'
        if contentType is 'text'
            models.Post.get { uid: req.params.item, network: req.network.stub }, {}, (err, post) =>
                comment = new models.Comment()
                comment.createdBy = req.user
                comment.forum = forum.stub
                comment.itemid = post._id.toString()
                comment.data = req.body.data
                comment.save {}, (err, comment)=>
                    res.send comment
                
        else
            next new AppError 'Unsupported Comment Type', 'UNSUPPORTED_COMMENT_TYPE'
        

    parseBody: (post, body) =>
        post.summary = {}

        if body.stub
            post.stub = body.stub.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')

        if body.title
            post.title = body.title
            post.summary.title = post.title

        if body.content
            post.content = body.content
            post.summary.text = post.content

        if body.cover
            post.cover = body.cover
            if body.coverTitle
                post.coverTitle = body.coverTitle
            post.summary.image = body.smallCover
        else
            post.cover = null
            post.coverTitle = null
            post.summary.image = null
    
exports.Posts = Posts
