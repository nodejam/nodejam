React = require('react-sandbox')

exports.renderForum = (data, ctx) ->*
    for post in data.posts
        typeDefinition = yield post.getTypeDefinition()
        extension = yield ctx.api.extensionLoader.load typeDefinition
        post.template = yield extension.getTemplateModule data.postTemplateFile
        
    options = {}
    if ctx.context.session
        options.loggedIn = true
        membership = yield data.forum.getMembership ctx.context.session.user.username
        if membership
            options.isMember = true
            options.primaryPostType = "Article"

    component = data.template { posts: data.posts, forum: data.forum, options }
    React.renderComponentToString(component)
    
    
exports.renderPost = (data, ctx) ->*
    author = yield data.post.getAuthor()
    typeDefinition = yield post.getTypeDefinition()
    
    extension = yield ctx.api.extensionLoader.load typeDefinition
    template = yield extension.getTemplateModule data.postTemplateFile
    component = data.template { 
        post: data.post,
        forum: data.forum, 
        author, 
        typeDefinition,
        template, 
    }
    React.renderComponentToString(component)


