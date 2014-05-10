db = require('../app').db
models = require '../../models'
auth = require '../../app-lib/web/auth'
ExtensionLoader = require('fora-extensions').Loader
loader = new ExtensionLoader()


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



###
    Display a list of forums.
###
exports.index = auth.handler ->*
    forums = yield models.Forum.find({ network: @network.stub }, { sort: { 'stats.lastPost': -1 }, limit: 32 }, {}, db)

    for forum in forums
        forum.summary = yield forum.getView("card", {}, db)

    yield @renderView 'forums/index', { forums }



###
    Load the forum's extension and pass control to it.
###
exports.page = auth.handler (stub) ->*
    forum = yield models.Forum.get { stub, network: @network.stub }, {}, db
    if forum
        extension = yield loader.load yield forum.getTypeDefinition()
        pages = yield extension.getPages()
        yield pages.handle new ForumExtensionContext(forum, extension, @)



###
    Create a new forum
###
exports.create = ->*
    yield @renderPage 'forums/new', { 
        pageName: 'create-forum-page', 
        pageLayout: {
            type: 'single-section-page fixed-width'
        }
    }        



###
    This code doesn't work. Move to extension
exports.about = (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, {}, db)        
    about = (yield forum.link 'info').about

    #We query admins and mods seperately since the fetch limits the posts returned per call
    leaders = yield forum.getMemberships(['admin','moderator'])
    admins = leaders.filter (u) -> u.roles.indexOf('admin') isnt -1
    moderators = leaders.filter (u) -> u.roles.indexOf('moderator') isnt -1 and u.roles.indexOf('admin') is -1
    members = (yield forum.getMemberships ['member']).filter (u) -> u.roles.indexOf('admin') is -1 and u.roles.indexOf('moderator') is -1
    
    yield @renderPage 'forums/about', {
        forum,
        about: if about then mdparser(about),
        admins,
        moderators,
        members,
        pageName: 'forum-about-page', 
        coverInfo: {
            cover: { 
                image: { src: forum.cover ? '/images/cover.jpg' } 
            },
        }
    }
###

