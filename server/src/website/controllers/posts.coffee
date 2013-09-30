controller = require './controller'
conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Q = require('../../common/q')

class Posts extends controller.Controller
    

    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try                
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                    post = yield models.Post.get({ 'forum.id': forum._id.toString(), stub: (req.params.stub) }, {}, db)
                    author = yield models.User.getById post.createdBy.id, {}, db

                    res.render req.network.getView('posttypes', post.constructor.getTypeDefinition().name), { 
                        post: post,
                        formatted: post.getFormattedFields(),
                        postJson: JSON.stringify(post),
                        author,
                        user: req.user,
                        forum,
                        editable: req.user?.id is author._id.toString(),
                        pageName: 'post-page', 
                        pageType: 'std-page', 
                    }
                    
                catch e
                    next e)()
            
        
            
exports.Posts = Posts
