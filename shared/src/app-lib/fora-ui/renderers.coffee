React = require('react')

module.exports = {
    simple: {

        ###
            Render a simple forum
        ###
        forum: (data, context) ->*
            typeDefinition = yield context.forum.getTypeDefinition()

            options = {}
            if context.client.session
                options.loggedIn = true
                membership = yield context.forum.getMembership context.client.session.user.username
                if membership
                    options.isMember = true
                    options.primaryPostType = "Article" #TODO: This makes no sense

            template = yield context.extension.getTemplateModule(data.forumTemplate)
            props = { posts: data.posts, forum: context.forum, postTemplate: data.postTemplate, options }

            script = "
                <script>
                    var page = new Fora.Views.Page(
                        '/shared/extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}.js',
                        #{JSON.stringify({ posts: data.posts, forum: context.forum, postTemplate: data.postTemplate, options })}
                    );
                </script>"

            yield context.client.render template, "/shared/extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}", props


        ###
            Render a simple post
        ###
        post: (data, context) ->*
            typeDefinition = yield context.forum.getTypeDefinition()
            author = yield data.post.getAuthor()

            options = {}
            if context.client.session
                options.loggedIn = true

            template = yield context.extension.getTemplateModule(data.forumTemplate)
            props = { post: data.post, forum: context.forum, author, postTemplate: data.postTemplate }

            yield context.client.render template, "/shared/extensions/#{typeDefinition.name}/templates/#{data.forumTemplate}", props


    }
}
