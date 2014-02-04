conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'
widgets = require '../../common/widgets'

exports.item = auth.handler (forum, post) ->*
    forum = yield models.Forum.get({ stub: forum, network: @network.stub }, {}, db)
    if forum
        post = yield models.Post.get({ 'forum.id': forum._id.toString(), stub: post }, {}, db)
        if post
            author = yield models.User.getById post.createdBy.id, {}, db
    
            viewModel = { 
                pageName: 'post-page',
                json: JSON.stringify(post),
                typeDefinition: JSON.stringify(yield post.getTypeDefinition()),
                user: @session.user,
            }
            
            pageTemplate = widgets.parse yield post.getTemplate 'standard'            
            result = pageTemplate.render { post, author, forum }
            
            if result.cover
                viewModel.cover = result.cover
                viewModel.coverContent = result.coverContent
            viewModel.html = result.html
            viewModel.pageType = result.pageType
            
            yield @render 'posts/post', viewModel
    
   
