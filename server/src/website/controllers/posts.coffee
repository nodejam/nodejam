conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'


exports.item = auth.handler (forum, post) ->*
    forum = yield models.Forum.get({ stub: forum, network: @network.stub }, {}, db)
    if forum
        post = yield models.Post.get({ 'forum.id': forum._id.toString(), stub: post }, {}, db)
        if post
            author = yield models.User.getById post.createdBy.id, {}, db
    
            viewModel = { 
                json: JSON.stringify(post),
                typeDefinition: JSON.stringify(yield post.getTypeDefinition()),
                user: @session.user,
                pageName: 'post-page',
            }
            
            pageTemplate = yield post.getTemplate 'standard'            
            contents = pageTemplate.render { post, author, forum }, viewModel
            
            yield @render 'posts/post', viewModel
    
   
