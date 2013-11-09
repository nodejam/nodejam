conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
Q = require('../../lib/q')
Controller = require('../../common/web/controller').Controller

class Collections extends Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>            
            stub = req.body('name').toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
            (Q.async =>
                try
                    collection = yield models.Collection.get({ network: req.network.stub, $or: [{ stub }, { name: req.body('name') }] }, { user: req.user }, db)
                    if collection
                        res.send 'A collection with the same name exists.'
                    else
                        collection = new models.Collection
                        collection.network = req.network.stub
                        collection.stub = stub
                        req.map collection, ['name', 'type', 'description', 'recordTypes', 'cover_src', 'cover_small', 'cover_alt']                        
                        collection.createdBy = req.user
                        collection = yield collection.save { user: req.user }, db

                        yield collection.addRole req.user, 'admin'
                        
                        info = new models.CollectionInfo {
                            collectionid: collection._id.toString(),
                            message: req.body('message'),
                            about: req.body('about')
                        }
                        
                        yield info.save { user: req.user }, db
                        
                        res.send collection

                catch e
                    next e)()                            


                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get({ stub: req.params('collection'), network: req.network.stub }, { user: req.user }, db)
                    if req.user.username is collection.createdBy.username or @isAdmin(req.user)
                        collection.description = req.body('description')
                        req.map collection, ['description', 'recordTypes', 'cover_src', 'cover_small', 'cover_alt']     
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
                    collection = yield models.Collection.get({ stub: req.params('collection'), network: req.network.stub }, { user: req.user }, db)
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
                    collection = yield models.Collection.get({ stub: req.params('collection'), network: req.network.stub }, { user: req.user }, db)
                    yield collection.join req.user
                    res.send { success: true }
                catch 
                    next e)()
                        

                
exports.Collections = Collections
