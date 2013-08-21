conf = require '../../../conf'
db = new (require '../../../common/database').Database(conf.db)
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
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
                        forum.network = req.network.stub
                        forum.type = req.body.type
                        forum.name = req.body.name
                        forum.description = req.body.description
                        forum.category = req.body.category
                        forum.icon = req.body.icon
                        forum.iconThumbnail = req.body.iconThumbnail
                        if req.body.cover             
                            forum.cover = req.body.cover
                        forum.stub = stub
                        forum.createdBy = req.user
                        forum.moderators.push req.user
                        forum.createdAt = Date.now()
                        forum.settings.comments = {
                            enable: if req.body.comments_enable then Boolean(req.body.comments_enable) else true
                            showByDefault: if req.body.comments_showByDefault then Boolean(req.body.comments_showByDefault) else true
                        }
                        forum = yield forum.save({ user: req.user }, db)
                        res.send forum
            
                        #Put a notification.
                        message = new models.Message {
                            userid: '0',
                            type: "global-notification",
                            reason: 'new-forum',
                            related: [ { type: 'user', id: req.user.id } ],
                            data: { forum }
                        }
                        message.save({ user: req.user }, db)
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
                        forum = yield forum.save({ user: req.user }, db)
                        res.send forum
                    else
                        next new AppError "Access denied.", 'ACCESS_DENIED'
                catch e
                    next e)()
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    forum = yield models.Forum.get({ stub: req.params.forum, network: req.network.stub }, { user: req.user }, db)
                    if @isAdmin(req.user)
                        yield forum.destroy({ user: req.user }, db)
                        res.send "DELETED #{forum.stub}."
                    else
                        next new AppError "Access denied.", 'ACCESS_DENIED'
                catch e
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
