conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller

class Posts extends Controller
            
    #Admin Features
    admin_update: (req, res, next) =>
        @ensureSession [req, res, next], =>
            if @isAdmin(req.user)
                models.Post.getById req.params.id, {}, (err, post) =>
                    if post
                        if req.body.meta
                            for meta in req.body.meta.split(',') 
                                if post.meta.indexOf(meta) is -1
                                    post.meta.push meta 
                            post.save {}, (err, post) =>
                                res.send post
                        else
                            next new AppError "Missing meta.", 'MISSING_META'       
                    else
                        next new AppError "Post not found.", 'POST_NOT_FOUND'   
            else
                next new AppError "Access denied.", 'ACCESS_DENIED'   
            
exports.Posts = Posts
