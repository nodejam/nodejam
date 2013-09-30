conf = require '../../conf'
database = (require '../../common/data/database').Database
db = new database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Controller = require('./controller').Controller
Q = require('../../common/q')
mdparser = require('../../common/lib/markdownutil').marked


class Forums extends Controller

    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    featured = yield models.Forum.find({ network: req.network.stub }, ((cursor) -> cursor.sort({ 'stats.lastPost': -1 }).limit 12), {}, db)
                    for forum in featured
                        forum.summary = forum.getView("card")
                        forum.summary.view = "standard"
                    
                    res.render req.network.getView('forums', 'index'), { 
                        featured, 
                        pageName: 'forums-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
            
    
    
    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)
                    message = yield forum.getField 'message'

                    if message
                        message = mdparser message
                        
                    posts = yield forum.getPosts(12, { _id: -1 })
                    for post in posts
                            post.summary = post.getView("card")
                            post.summary.view = "standard"

                    options = {}
                    if req.user
                        membership = yield models.Membership.get { 'forum.id': forum._id.toString(), 'user.id': req.user.id }, {}, db
                        if membership
                            options.isMember = true
                            options.primaryPostType = forum.postTypes[0]
                            
                    res.render req.network.getView('forums', 'item'), { 
                        forum,
                        forumJson: JSON.stringify(forum),
                        message,
                        posts, 
                        options,
                        user: req.user,
                        pageName: 'forum-page', 
                        pageType: 'cover-page', 
                        cover: forum.cover ? '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()



    about: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try                
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, {}, db)        
                    about = yield forum.getField 'about'

                    #We query admins and mods seperately since the fetch limits the records returned per call
                    leaders = yield forum.getMemberships(['admin','moderator'])
                    admins = leaders.filter (u) -> u.roles.indexOf('admin') isnt -1
                    moderators = leaders.filter (u) -> u.roles.indexOf('moderator') isnt -1 and u.roles.indexOf('admin') is -1
                    members = (yield forum.getMemberships ['member']).filter (u) -> u.roles.indexOf('admin') is -1 and u.roles.indexOf('moderator') is -1
                    
                    res.render req.network.getView('forums', 'about'), {
                        forum,
                        about: if about then mdparser(about),
                        admins,
                        moderators,
                        members,
                        pageName: 'forum-about-page', 
                        pageType: 'cover-page', 
                        cover: forum.cover ? '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
                    

exports.Forums = Forums
