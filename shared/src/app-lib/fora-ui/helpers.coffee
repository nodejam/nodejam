React = require('fora-react-sandbox')

exports.renderForum = (data, context) ->*
    typeDefinition = yield context.forum.getTypeDefinition()
    
    options = {}

    if context.client.session
        options.loggedIn = true
        membership = yield context.forum.getMembership context.client.session.user.username
        if membership
            options.isMember = true
            options.primaryPostType = "Article" #TODO: This makes no sense
            
    template = yield context.extension.getTemplateModule(data.forumTemplate)

    component = template { posts: data.posts, forum: context.forum, postTemplate: data.postTemplate, options }
    if component.type.componentInit and not component.__isInitted
        yield component.type.componentInit component

    script = "
        <script>
            var page = new Fora.Views.Page(
                '/shared/extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}.js',
                #{JSON.stringify({ posts: data.posts, forum: context.forum, postTemplate: data.postTemplate, options })}
            );
        </script>"

    params = {
        html: "#{script} #{React.renderComponentToString(component)}",  
        pageName: "forum-item-page",
    }
    params.theme ?= context.client.network.theme         
    params.coverInfo?.class ?= "auto-cover"                            

    if context.client.session
        params._session ?= context.client.session.user

    yield context.client.render "page", params

    
    
exports.renderPost = (data, context) ->*
    typeDefinition = yield context.forum.getTypeDefinition()
    author = yield data.post.getAuthor()

    options = {}
    if context.client.session
        options.loggedIn = true

    template = yield context.extension.getTemplateModule(data.forumTemplate)

    component = template { post: data.post, forum: context.forum, author, postTemplate: data.postTemplate }
    if component.type.componentInit and not component.__isInitted
        yield component.type.componentInit component
    
    script = "
        <script>
            var page = new Fora.Views.Page(
                '/shared/extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}.js',
                #{JSON.stringify({ post: data.post, forum: context.forum, author, postTemplate: data.postTemplate })}
            );
        </script>"

    params = {
        html: "#{script} #{React.renderComponentToString(component)}",  
        pageName: "forum-item-page",
    }
    params.theme ?= context.client.network.theme         
    params.coverInfo?.class ?= "auto-cover"                            

    if context.client.session
        params._session ?= context.client.session.user

    yield context.client.render "page", params

