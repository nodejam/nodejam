conf = require '../../../conf'
db = new (require '../../../common/data/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
Controller = require('../controller').Controller
Q = require('../../../common/q')

class Posts extends Controller
            
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
