controllers = require './'
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
controller = require '../controller'

class Forums extends controller.Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>
            stub = req.body.name.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')

            models.Collection.get { network: req.network.stub, $or: [{ stub }, { name: req.body.name }] }, {}, (err, forum) =>
                if forum
                    res.send 'A forum with the same name exists.'
                else
                    forum = new models.Collection
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
                        enable: true
                    }
                    @getTypeSpecificController(forum.type).createCollection req, res, next, forum
                
                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            models.Collection.get { stub: req.params.forum, network: req.network.stub }, {}, (err, forum) =>
                if req.user.id is forum.createdBy.id or @isAdmin(req.user, req.network)
                    forum.description = req.body.description
                    forum.icon = req.body.icon
                    forum.iconThumbnail = req.body.iconThumbnail 
                    if req.body.cover                   
                        forum.cover = req.body.cover
                    else
                        forum.cover = ''
                    forum.tile = req.body.tile ? '/images/forum-tile.png'                                        
                    forum.save {}, (err, coll) =>            
                        res.send coll                
                else
                    next new AppError "Access denied.", 'ACCESS_DENIED'
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            models.Collection.get { stub: req.params.forum, network: req.network.stub }, {}, (err, forum) =>
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
            
            
    addItemComment: (req, res, next) =>
        @invokeTypeSpecificController arguments, (c) -> c.addComment
        
                        
    invokeTypeSpecificController: ([req, res, next], getHandler) =>            
        @ensureSession [req, res, next], =>
            models.Collection.get { stub: req.params.forum, network: req.network.stub }, {}, (err, forum) =>
                if not err
                    if forum
                        getHandler(@getTypeSpecificController(forum.type)) req, res, next, forum
                    else
                        res.render '404.hbs', { layout: false }                                   
                else
                    next err            


    getTypeSpecificController: (type) =>
        switch type
            when 'post'
                return new controllers.Posts()
                        
                
exports.Forums = Forums
