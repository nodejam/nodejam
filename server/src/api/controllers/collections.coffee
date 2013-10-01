conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Controller = require('./controller').Controller
Q = require('../../common/q')

class Collections extends Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>            
            stub = req.body.name.toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
            (Q.async =>
                try
                    collection = yield models.Collection.get({ network: req.network.stub, $or: [{ stub }, { name: req.body.name }] }, { user: req.user }, db)
                    if collection
                        res.send 'A collection with the same name exists.'
                    else
                        collection = new models.Collection
                        collection.stub = stub
                        collection.network = req.network.stub
                        collection.name = req.body.name
                        collection.type = req.body.type ? 'public'
                        collection.description = req.body.description
                        collection.category = req.body.category
                        collection.icon = req.body.icon
                        collection.iconThumbnail = req.body.iconThumbnail                                                
                        collection.recordTypes = if req.body.recordTypes then req.body.recordTypes.split(',') else ['article']
                        collection.cover = req.body.cover
                        collection.createdBy = req.user
                        collection.createdAt = Date.now()
                        collection.settings = new models.Collection.Settings
                        
                        collection.settings.comments = {
                            enabled: if req.body.settings_comments_enable is "false" then false
                            opened: if req.body.settings_comments_opened is "false" then false
                        }
                        
                        collection = yield collection.save { user: req.user }, db

                        yield collection.addRole req.user, 'admin'
                        
                        if req.body.message
                            yield collection.saveField 'message', req.body.message

                        if req.body.about
                            yield collection.saveField 'about', req.body.about
                        
                        res.send collection
            
                        #Put a notification.
                        message = new models.Message {
                            userid: '0',
                            type: "global-notification",
                            reason: 'new-collection',
                            related: [ { type: 'user', id: req.user.id } ],
                            data: { collection }
                        }
                        message.save { user: req.user }, db
                catch e
                    next e)()                            


                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get({ stub: req.params.collection, network: req.network.stub }, { user: req.user }, db)
                    if req.user.id is collection.createdBy.id or @isAdmin(req.user)
                        collection.description = req.body.description
                        collection.icon = req.body.icon
                        collection.iconThumbnail = req.body.iconThumbnail 
                        if req.body.cover                   
                            collection.cover = req.body.cover
                        else
                            collection.cover = ''
                        collection.tile = req.body.tile ? '/images/collection-tile.png'                                        
                        collection = yield collection.save()
                        res.send collection
                    else
                        next new Error "Access denied"
                catch e
                    next e)()
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get({ stub: req.params.collection, network: req.network.stub }, { user: req.user }, db)
                    if @isAdmin(req.user)
                        yield collection.destroy()
                        res.send { success: true }
                    else
                        next new Error "Access denied"
                catch e
                    next e)()



    join: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get({ stub: req.params.collection, network: req.network.stub }, { user: req.user }, db)
                    yield collection.join req.user
                    res.send { success: true }
                catch 
                    next e)()
                        

                
exports.Collections = Collections
