conf = require '../../conf'
db = require('../app').db
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
    
            pageTemplate = widgets.parse yield post.getTemplate 'item'            
            
            yield @renderPage 'posts/post', { 
                pageName: 'post-page',
                json: JSON.stringify(post),
                theme: pageTemplate.getTheme() ? forum.theme
                typeDefinition: JSON.stringify(yield post.getTypeDefinition()),
                html: pageTemplate.render { post, author, forum }
            }
    
   
