React = require('react-sandbox')

exports.renderForum = (data, ctx) ->*
    options = {}
    if ctx.context.session
        options.loggedIn = true
        membership = yield data.forum.getMembership ctx.context.session.user.username
        if membership
            options.isMember = true
            options.primaryPostType = "Article" #TODO: This makes no sense

    typeDefinition = yield data.forum.getTypeDefinition()
    forumExtension = yield ctx.getForumExtension()
    template = require("../../extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}")
    component = template { posts: data.posts, forum: data.forum, options }
    
    script = "
        <script>
            var page = new Fora.Views.Page(
                '/shared/extensions/#{forumExtension.name}/templates/#{data.forumTemplate}.js',
                #{JSON.stringify({ posts: data.posts, forum: data.forum, options })}
            );
        </script>"
    
    html = "
        #{script}
        #{React.renderComponentToString(component)}    
    "
    
    
    
exports.renderPost = (data, ctx) ->*
    author = yield data.post.getAuthor()
    typeDefinition = yield post.getTypeDefinition()
    
    extension = yield ctx.getForumExtension()
    template = yield extension.getTemplateModule data.postTemplate
    component = data.template { 
        post: data.post,
        forum: data.forum, 
        author, 
        typeDefinition,
        template,
    }
    return "
        <script>
            var page = new Fora.Views.Page(
                '/shared/extensions/#{extension.name}/templates/index.js',
                #{JSON.stringify({ editorsPicks, featured, cover, coverContent })}
            );
        </script>
        #{React.renderComponentToString(component)}
    "


