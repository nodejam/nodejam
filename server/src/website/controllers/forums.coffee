React = require 'react'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
fields = require '../../models/fields'
utils = require '../../lib/utils'
mdparser = require('../../lib/markdownutil').marked
auth = require '../../app-libs/web/auth'
widgets = require '../../app-libs/widgets'
ExtensionLoader = require '../../app-libs/extensions/loader'
loader = new ExtensionLoader()


class ForumContext

    constructor: (@context, @forum) ->
    
    
    getForum: ->* @forum
    
    
    getExtension: (object) ->*
        yield loader.load yield object.getTypeDefinition()
                      
        
    renderPage: ->*
    
    
    renderPost: (data) ->*
        yield @context.renderPage 'posts/post', { 
            pageName: 'post-page',
            theme: data.forum.theme,
            json: JSON.stringify(data.post),
            typeDefinition: JSON.stringify(yield data.post.getTypeDefinition()),
            html: data.html
        }


exports.index = auth.handler ->*
    featured = yield models.Forum.find({ network: @network.stub }, { sort: { 'stats.lastPost': -1 }, limit: 32 }, {}, db)
    for forum in featured
        forum.summary = yield forum.getView("card", {}, db)
    
    yield @renderPage 'forums/index', { 
        pageName: 'forums-page',
        featured
    }



exports.page = auth.handler (stub) ->*
    forum = yield models.Forum.get { stub, network: @network.stub }, {}, db
    if forum
        extension = yield loader.load yield forum.getTypeDefinition()
        pages = yield extension.getPages()
        component = yield pages.handle new ForumContext(@, forum)
        html = React.renderComponentToString component
        yield @renderPage 'posts/post', { 
            pageName: 'post-page',
            html
        }



exports.item = auth.handler (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, {}, db)
    info = yield forum.link 'info'

    if forum
        posts = yield forum.getPosts(12, db.setRowId({}, -1))

        for post in posts
            post.html = yield models.Post.render 'card', { post, forum: post.forum, author: post.createdBy }

        options = {}
        if @session.user
            membership = yield models.Membership.get { 'forum.id': db.getRowId(forum), 'user.username': @session.user.username }, {}, db
            if membership
                options.isMember = true
        
        coverContent = "
            <h1>#{forum.name}</h1>
            <p data-field-type=\"plain-text\" data-field-name=\"description\">#{forum.description}</p>
            <div class=\"option-bar\"><button class=\"edit\">Edit</button></div>"
            
        forum.cover ?= new fields.Cover { image: new fields.Image { src: '/images/forum-cover.jpg', small: '/images/forum-cover-small.jpg', alt: forum.name } }
        
        yield @renderPage 'forums/item', { 
            forum,
            forumJson: JSON.stringify(forum),
            message: if info.message then mdparser(info.message),
            posts, 
            options,
            pageName: 'forum-page', 
            coverInfo: {
                cover: forum.cover,
                content: coverContent
            }
        }



exports.create = ->*
    yield @renderPage 'forums/new', { 
        pageName: 'create-forum-page', 
        pageLayout: {
            type: 'single-section-page fixed-width'
        }                        
    }        



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

