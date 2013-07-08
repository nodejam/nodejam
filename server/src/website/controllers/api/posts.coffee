conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller

class Posts extends Controller
            
    #Admin Features
    adminUpdate: (req, res, next) =>
        @ensureSession [req, res, next], =>
            if @isAdmin(req.user, req.network)
                models.Post.getById req.params.id, {}, (err, post) =>
                    if req.body.tags
                        for tag in req.body.tags.split(',') 
                            if post.tags.indexOf(tag) is -1
                                post.tags.push tag 
                        post.save {}, (err, post) =>
                            res.send post
            else
                next new AppError "Access denied.", 'ACCESS_DENIED'   
            
exports.Posts = Posts
