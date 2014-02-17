conf = require '../../conf'
database = (require '../../lib/data/database').Database
db = new database(conf.db)
models = require '../../models'
fields = require '../../models/fields'
utils = require '../../lib/utils'
mdparser = require('../../lib/markdownutil').marked
auth = require '../../common/web/auth'
widgets = require '../../common/widgets'


exports.index = auth.handler ->*
    featured = yield models.Forum.find({ network: @network.stub }, ((cursor) -> cursor.sort({ 'stats.lastPost': -1 }).limit 32), {}, db)
    for forum in featured
        forum.summary = forum.getView("card")
    
    yield @renderPage 'forums/index', { 
        pageName: 'forums-page',
        featured
    }



exports.item = auth.handler (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, {}, db)
    info = yield forum.link 'info'

    if forum
        posts = yield forum.getPosts(12, { _id: -1 })
        for post in posts
            template = widgets.parse yield post.getTemplate 'card'
            post.html = template.render {
                post,
                forum: post.forum,
            }

        options = {}
        if @session.user
            membership = yield models.Membership.get { 'forum.id': forum._id.toString(), 'user.username': @session.user.username }, {}, db
            if membership
                options.isMember = true
                options.primaryPostType = forum.postTypes[0]
        
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
    yield @renderPage 'forums/create', { 
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

