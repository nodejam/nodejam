###
    The data structure passed to forum extensions.
###
class ForumExtensionContext

    constructor: (@forum, @extension, @client) ->
    
    
    renderPost: (data) ->*
        yield @context.renderPage 'posts/post', { 
            pageName: 'post-page',
            theme: data.forum.theme,
            json: JSON.stringify(data.post),
            typeDefinition: JSON.stringify(yield data.post.getTypeDefinition()),
            html: data.html
        }


module.exports = ({typeUtils, models, fields, db, conf, auth, mapper, loader }) -> {

    ###
        Display a list of forums.
    ###
    index: auth.handler ->*
        forums = yield models.Forum.find({ network: @network.stub }, { sort: { 'stats.lastPost': -1 }, limit: 32 }, {}, db)

        for forum in forums
            forum.summary = yield forum.getView("card", {}, db)

        yield @renderView 'forums/index', { forums }



    ###
        Load the forum's extension and pass control to it.
    ###
    page: auth.handler (stub) ->*
        forum = yield models.Forum.get { stub, network: @network.stub }, {}, db
        if forum
            extension = yield extensionLoader.load yield forum.getTypeDefinition()
            pages = yield extension.getPages()
            yield pages.handle new ForumExtensionContext(forum, extension, @)



    ###
        Create a new forum
    ###
    create: ->*
        yield @renderPage 'forums/new', { 
            pageName: 'create-forum-page', 
            pageLayout: {
                type: 'single-section-page fixed-width'
            }
        }        
        
}
