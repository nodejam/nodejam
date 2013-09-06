conf = require '../../../conf'
db = new (require '../../../common/data/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
Controller = require('../controller').Controller
controllers = require './'
Q = require('../../../common/q')

class Forums extends Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>            
            stub = req.body.name.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
            (Q.async =>
                try
                    forum = yield models.Forum.get({ network: req.network.stub, $or: [{ stub }, { name: req.body.name }] }, { user: req.user }, db)
                    if forum
                        res.send 'A forum with the same name exists.'
                    else
                        forum = new models.Forum
                        forum.stub = stub
                        forum.network = req.network.stub
                        forum.name = req.body.name
                        forum.type = req.body.type ? 'public'
                        forum.description = req.body.description
                        forum.category = req.body.category
                        forum.icon = req.body.icon
                        forum.iconThumbnail = req.body.iconThumbnail

                        if req.body.cover             
                            forum.cover = req.body.cover

                        
                        forum.createdBy = req.user
                        forum.createdAt = Date.now()
                        forum.settings = new models.Forum.Settings
                        
                        forum.settings.comments = {
                            enabled: if req.body.settings_comments_enable is "false" then false
                            opened: if req.body.settings_comments_opened is "false" then false
                        }
                        
                        forum = yield forum.save { user: req.user }, db

                        yield forum.addRole req.user, 'admin'
                        
                        if req.body.message
                            yield forum.saveField 'message', req.body.message

                        if req.body.about
                            yield forum.saveField 'about', req.body.about
                        
                        res.send forum
            
                        #Put a notification.
                        message = new models.Message {
                            userid: '0',
                            type: "global-notification",
                            reason: 'new-forum',
                            related: [ { type: 'user', id: req.user.id } ],
                            data: { forum }
                        }
                        message.save { user: req.user }, db
                catch e
                    next e)()                            


                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                    if req.user.id is forum.createdBy.id or @isAdmin(req.user)
                        forum.description = req.body.description
                        forum.icon = req.body.icon
                        forum.iconThumbnail = req.body.iconThumbnail 
                        if req.body.cover                   
                            forum.cover = req.body.cover
                        else
                            forum.cover = ''
                        forum.tile = req.body.tile ? '/images/forum-tile.png'                                        
                        forum = yield forum.save()
                        res.send forum
                    else
                        next new Error "Access denied"
                catch e
                    next e)()
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                    if @isAdmin(req.user)
                        yield forum.destroy()
                        res.send { success: true }
                    else
                        next new Error "Access denied"
                catch e
                    next e)()



    join: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                    yield forum.join req.user
                    res.send { success: true }
                catch 
                    next e)()
        
        

    createItem: (req, res, next) =>
        @ensureSession arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.create



    editItem: (req, res, next) =>
        @ensureSession arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.edit


                
    removeItem: (req, res, next) =>
        @ensureSession arguments, =>
            @invokeTypeSpecificController req, res, next, (c) -> c.remove
            
                                   
                                    
    invokeTypeSpecificController: (req, res, next, getHandler) =>   
        (Q.async =>
            try
                forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                getHandler(@getTypeSpecificController(req.body.type)) req, res, next, forum
            catch e
                next e)()



    getTypeSpecificController: (type) =>
        switch type
            when 'article'
                return new controllers.Articles()
                        
                        

                
exports.Forums = Forums
