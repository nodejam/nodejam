conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Controller = require('./controller').Controller
controllers = require './'
Q = require('../../common/q')

class Posts extends Controller

    create: (req, res, next) =>
        @ensureSession arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.create



    edit: (req, res, next) =>
        @ensureSession arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.edit


                
    remove: (req, res, next) =>
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
            
                                   
                                    
    invokeTypeSpecificController: (req, res, next, getHandler) =>   
        (Q.async =>
            try
                forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                getHandler(@getTypeSpecificController(req.body.type)) req, res, next, forum
            catch e
                next e)()



    getTypeSpecificController: (type) =>
        switch type
            when 'article'
                return new controllers.Articles()


            
    addComment: (req, res, next, forum) =>        
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
