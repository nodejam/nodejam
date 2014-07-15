React = require('react')

module.exports = {
    simple: {

        ###
            Render a simple forum
        ###
        forum: (props, context) ->*
            typeDefinition = yield* context.forum.getTypeDefinition()

            options = {}
            if context.koaContext.session
                options.loggedIn = true
                membership = yield* context.forum.getMembership context.koaContext.session.user.username
                if membership
                    options.isMember = true
                    options.primaryPostType = "Article" #TODO: This makes no sense

            template = yield* context.extension.getTemplateModule(props.forumTemplate)
            props = { posts: props.posts, forum: context.forum, forumTemplate: props.forumTemplate, postTemplate: props.postTemplate, options }

            script = "
                <script>
                    var page = new Fora.Views.Page(
                        '/js/extensions/#{typeDefinition.name}/templates/#{props.forumTemplate}.js',
                        #{JSON.stringify({ posts: props.posts, forum: context.forum, postTemplate: props.postTemplate, options })}
                    );
                </script>"

            context.koaContext.body = yield* context.koaContext.render template, "/js/extensions/#{typeDefinition.name}/templates/#{props.forumTemplate}", props

        ###
            Render a simple post
        ###
        post: (props, context) ->*
            typeDefinition = yield* context.forum.getTypeDefinition()
            author = yield* props.post.getAuthor()

            options = {}
            if context.koaContext.session
                options.loggedIn = true

            template = yield* context.extension.getTemplateModule(props.forumTemplate)
            props = { post: props.post, forum: context.forum, author, forumTemplate: props.forumTemplate, postTemplate: props.postTemplate }

            context.koaContext.body = yield* context.koaContext.render template, "/js/extensions/#{typeDefinition.name}/templates/#{props.forumTemplate}", props
    }
}
