conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller

class Posts extends Controller
            
    #Admin Features
    admin_update: (req, res, next) =>
        @ensureSession [req, res, next], =>
            if @isAdmin(req.user)
                models.Post.getById(req.params.id, { user: req.user }, db)
                    .then (post) =>
                        if post 
                            if req.body.meta
                                for meta in req.body.meta.split(',') 
                                    if post.meta.indexOf(meta) is -1
                                        post.meta.push meta
                                post.save({ user: req.user }, db)                                    
                                    .then =>
                                        res.send post
                        else
                            next new AppError "Post not found.", 'POST_NOT_FOUND'   
            else
                next new AppError "Access denied.", 'ACCESS_DENIED'   
            
exports.Posts = Posts
