conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
Controller = require('../controller').Controller
controllers = require './'

class Forums extends Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>
            stub = req.body.name.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
            models.Forum.get { network: req.network.stub, $or: [{ stub }, { name: req.body.name }] }, {}, (err, forum) =>
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
                    forum.save {}, (err, forum) =>
                        res.send forum
        
                    #Put a notification.
                    message = new models.Message {
                        network: req.network.stub,
                        userid: '0',
                        type: "global-notification",
                        reason: 'new-forum',
                        related: [ { type: 'user', id: req.user.id } ],
                        data: { forum }
                    }
                    message.save {}, (err, msg) =>  
                                

                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            models.Forum.get { stub: req.params.forum, network: req.network.stub }, {}, (err, forum) =>
                if req.user.id is forum.createdBy.id or @isAdmin(req.user, req.network)
                    forum.description = req.body.description
                    forum.icon = req.body.icon
                    forum.iconThumbnail = req.body.iconThumbnail 
                    if req.body.cover                   
                        forum.cover = req.body.cover
                    else
                        forum.cover = ''
                    forum.tile = req.body.tile ? '/images/forum-tile.png'                                        
                    forum.save {}, (err, forum) =>            
                        res.send forum                
                else
                    next new AppError "Access denied.", 'ACCESS_DENIED'
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            models.Forum.get { stub: req.params.forum, network: req.network.stub }, {}, (err, forum) =>
                if @isAdmin(req.user, req.network)
                    forum.destroy {}, => res.send "DELETED #{forum.stub}."
                else
                    next new AppError "Access denied.", 'ACCESS_DENIED'



    createItem: (req, res, next) =>
        @invokeTypeSpecificController arguments, (c) -> c.create


    editItem: (req, res, next) =>
        @invokeTypeSpecificController arguments, (c) -> c.edit

                
    removeItem: (req, res, next) =>
        @invokeTypeSpecificController arguments, (c) -> c.remove
            
                                    
    invokeTypeSpecificController: ([req, res, next], getHandler) =>   
        @ensureSession [req, res, next], =>
            models.Forum.get { network: req.network.stub, stub: req.params.forum }, {}, (err, forum) =>
                getHandler(@getTypeSpecificController(req.body.type)) req, res, next, forum


    getTypeSpecificController: (type) =>
        switch type
            when 'article'
                return new controllers.Articles()
                        
                        

                
exports.Forums = Forums
