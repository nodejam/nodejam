conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
typeUtil = require '../../common/data/typeutil'
Controller = require('./controller').Controller
controllers = require './'
Q = require('../../common/q')

class Posts extends Controller


    create: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get { stub: req.params.forum, network: req.network.stub }, { user: req.user }, db
                    type = models.Post.getTypeDefinition().discriminator req.body        
                
                    post = new type()
                    post.type = req.body.type
                    post.createdBy = req.user
                    post.rating = 0

                    if req.body.publish is 'true'
                        post.state = 'published'
                    else
                        post.state = 'draft'
                    post.savedAt = Date.now()

                    for fieldName, def of type.getTypeDefinition(type, false).fields
                        def = typeUtil.getFullTypeDefinition def
                        
                        if req.body[fieldName]
                            switch def.type
                                when "string"                        
                                    post[fieldName] = req.body[fieldName]
                        else
                            if def.default
                                if typeof def.default is "function"
                                    post[fieldName] = def.default.call post, req.body
                                else
                                    post[fieldName] = def.default
                    
                    post = yield forum.addPost post
                    res.send post

                catch e
                    utils.dumpError e
                    next e
            )()



    edit: (req, res, next) =>
        @ensureSession arguments, =>        
            (Q.async =>
                try
                    forum = yield models.Forum.get { stub: req.params.forum, network: req.network.stub }, { user: req.user }, db
                    type = models.Post.getTypeDefinition().discriminator req.body        
                    post = yield type.getById(req.params.post, { user: req.user }, db)
                    
                    if post
                        if post.createdBy.id is req.user.id or @isAdmin(req.user)
                            post.savedAt ?= Date.now()
                            
                            #Add update code here...
                            
                            post = yield post.save()                            
                            res.send post

                        else
                            res.send 'Access denied.'
                    else
                        res.send 'Invalid post.'
                catch e
                    next e)()    


                
    remove: (req, res, next) =>
        @ensureSession arguments, => 
            (Q.async =>
                try
                    post = yield models.Post.getById(req.params.post, { user: req.user }, db)
                    if post
                        if post.createdBy.id is req.user.id or @isAdmin(req.user)
                            post = yield post.destroy()
                            res.send post
                        else
                            res.send 'Access denied.'
                    else
                        res.send "Invalid article."
                catch e
                    next e)()    
                     

            
    addComment: (req, res, next, forum) =>        
        @attachUser arguments, => 
            contentType = forum.settings?.comments?.contentType ? 'text'
            if contentType is 'text'
                (Q.async =>
                    try
                        post = yield models.Post.getById(req.params.post, { user: req.user }, db)
                        comment = new models.Comment()
                        comment.createdBy = req.user
                        comment.forum = forum.stub
                        comment.itemid = post._id.toString()
                        comment.data = req.body.data
                        comment = yield comment.save({ user: req.user }, db)
                        res.send comment
                    catch e
                        next e)()                
            else
                next new Error 'Unsupported Comment Type'



    #Admin Features
    admin_update: (req, res, next) =>
        @ensureSession [req, res, next], =>
            if @isAdmin(req.user)
                (Q.async =>
                    try
                        post = yield models.Post.getById(req.params.id, { user: req.user }, db)
                        if post 
                            if req.body.meta
                                post = yield post.addMetaList req.body.meta.split(',')
                            res.send post
                        else
                            next new Error "Post not found"
                    catch e
                        next e)()
            else
                next new Error "Access denied"


exports.Posts = Posts

