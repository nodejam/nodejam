conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
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
                                for meta in req.body.meta.split(',') 
                                    if post.meta.indexOf(meta) is -1
                                        post.meta.push meta
                                yield post.save({ user: req.user }, db)                                    
                            res.send post
                        else
                            next new AppError "Post not found.", 'POST_NOT_FOUND'   
                    catch e
                        next e)()
            else
                next new AppError "Access denied.", 'ACCESS_DENIED'   
            
exports.Posts = Posts
