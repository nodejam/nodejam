conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
Q = require '../../lib/q'
Controller = require('../../common/web/controller').Controller

class Posts extends Controller

    create: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>*
                try
                    forum = yield models.Forum.get { stub: req.params('forum'), network: req.network.stub }, { user: req.user }, db
                    type = models.Post.getTypeDefinition().discriminator { type: req.body('type') }
                    
                    post = new type {
                        createdBy: req.user,
                        state: req.body('state'),
                        rating: 0,
                        savedAt: Date.now(),
                    }
                    
                    req.map post, @getMappableFields(type)
                    
                    post = yield forum.addPost post
                    res.send post

                catch e
                    next e
            )()



    edit: (req, res, next) =>
        @ensureSession arguments, =>        
            (Q.async =>*
                try
                    forum = yield models.Forum.get { stub: req.params('forum'), network: req.network.stub }, { user: req.user }, db
                    post = yield models.Post.getById(req.params('id'), { user: req.user }, db)
                    type = post.constructor
                    
                    if post
                        if post.createdBy.username is req.user.username or @isAdmin(req.user)
                            post.savedAt = Date.now()                       
                            req.map post, @getMappableFields(type)
                            if req.body('state') is 'published'
                                post.state = 'published'
                            post = yield post.save()
                            res.send post
                        else
                            res.send 'Access denied.'
                    else
                        res.send 'Invalid post.'
                catch e
                    next e)()

    
    ###
        All fields defined specifically in a class inherited from Post will be 'mappable'.
        models.Post.getTypeDefinition(type, false) returns fields in inherited class.
        Note: fields in Post are not mappable.
    ###    
    getMappableFields: (type, acc = [], prefix = []) =>
        typeUtils = models.Post.getTypeUtils()
        
        for field, def of type.getTypeDefinition(false).fields
            if typeUtils.isPrimitiveType def.type
                acc.push prefix.concat(field).join '_'
            else
                if typeUtils.isUserDefinedType def.type
                    prefix.push field
                    @getMappableFields def.ctor, acc, prefix
                    prefix.pop field            
        acc
        
                
                
    remove: (req, res, next) =>
        @ensureSession arguments, => 
            (Q.async =>*
                try
                    post = yield models.Post.getById(req.params('post'), { user: req.user }, db)
                    if post
                        if post.createdBy.username is req.user.username or @isAdmin(req.user)
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
                (Q.async =>*
                    try
                        post = yield models.Post.getById(req.params('post'), { user: req.user }, db)
                        comment = new models.Comment()
                        comment.createdBy = req.user
                        comment.forum = forum.stub
                        comment.itemid = post._id.toString()
                        comment.data = req.body('data')
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
                (Q.async =>*
                    try
                        post = yield models.Post.getById(req.params('id'), { user: req.user }, db)
                        if post 
                            if req.body('meta')
                                post = yield post.addMetaList req.body('meta').split(',')
                            res.send post
                        else
                            next new Error "Post not found"
                    catch e
                        next e)()
            else
                next new Error "Access denied"


exports.Posts = Posts

