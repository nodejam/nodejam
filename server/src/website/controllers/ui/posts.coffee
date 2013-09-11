controller = require '../controller'
conf = require '../../../conf'
db = new (require '../../../common/data/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
Q = require('../../../common/q')
templates = require('./templates/posts')

class Posts extends controller.Controller
    

    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try                
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                    post = yield models.Post.get({ 'forum.id': forum._id.toString(), stub: (req.params.stub) }, {}, db)
                    user = yield models.User.getById(post.createdBy.id, {}, db)
                    template = templates.getTemplate 'default', post
                    template.render req, res, next, forum, post, user, { editable: req.user?.id is user._id.toString() }
                catch e
                    next e)()
            
        
            
exports.Posts = Posts
