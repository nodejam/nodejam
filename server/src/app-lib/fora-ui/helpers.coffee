React = require('react')

exports.renderForum = (data, ctx) ->*
    for post in data.posts
        extension = yield ctx.api.extensionLoader.load yield post.getTypeDefinition()
        post.template = yield extension.getTemplate(data.postTemplate)
        
    options = {}
    if ctx.context.session
        options.loggedIn = true
        membership = yield data.forum.getMembership ctx.context.session.user.username
        if membership
            options.isMember = true
            options.primaryPostType = "Article"

    component = data.template { posts: data.posts, forum: data.forum, options }
    return React.renderComponentToString component
    
    
exports.renderPost = (data, ctx) ->*
    author = yield data.post.getAuthor()
    typeDefinition = yield post.getTypeDefinition()
    
    extension = yield ctx.api.extensionLoader.load(typeDefinition)
    template = yield extension.getTemplate(data.postTemplate)
    component = data.template { 
        post: data.post, 
        forum: data.forum, 
        author, 
        typeDefinition,
        template: template, 
    }
    return React.renderComponentToString component

