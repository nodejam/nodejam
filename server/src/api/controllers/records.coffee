conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
Q = require('../../lib/q')
Controller = require('../../common/web/controller').Controller

class Records extends Controller

    create: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get { stub: req.params('collection'), network: req.network.stub }, { user: req.user }, db
                    type = models.Record.getTypeDefinition().discriminator { type: req.body('type') }
                
                    record = new type {
                        type: req.body('type'),
                        createdBy: req.user,
                        state: req.body('state') ? 'draft',
                        rating: 0,
                        savedAt: Date.now(),
                        format: 'html'
                    }
                    req.map record, @getMappableFields(type)
                    record = yield collection.addRecord record
                    res.send record

                catch e
                    utils.dumpError e
                    next e
            )()



    edit: (req, res, next) =>
        @ensureSession arguments, =>        
            (Q.async =>
                try
                    collection = yield models.Collection.get { stub: req.params('collection'), network: req.network.stub }, { user: req.user }, db
                    record = yield models.Record.getById(req.params('record'), { user: req.user }, db)
                    type = record.constructor
                    
                    if record
                        if record.createdBy.id is req.user.id or @isAdmin(req.user)
                            record.savedAt = Date.now()                       
                            req.map record, @getMappableFields(type)
                            record = yield record.save()
                            res.send record
                        else
                            res.send 'Access denied.'
                    else
                        res.send 'Invalid record.'
                catch e
                    next e)()

    
    ###
        All fields defined specifically in a class inherited from Record will be 'mappable'.
        models.Record.getTypeDefinition(type, false) returns fields in inherited class.
        Note: fields in Record are not mappable.
    ###    
    getMappableFields: (type, acc = [], prefix = []) =>
        typeUtils = models.Record.getTypeUtils()
        
        for field, def of type.getTypeDefinition(false).fields
            def = typeUtils.getFieldDefinition def
            if typeUtils.isPrimitiveType def.type
                acc.push prefix.concat(field).join '_'
            else
                if typeUtils.isUserDefinedType def.type
                    prefix.push field
                    @getMappableFields def.type, acc, prefix
                    prefix.pop field            
        acc
        
                
    remove: (req, res, next) =>
        @ensureSession arguments, => 
            (Q.async =>
                try
                    record = yield models.Record.getById(req.params('record'), { user: req.user }, db)
                    if record
                        if record.createdBy.id is req.user.id or @isAdmin(req.user)
                            record = yield record.destroy()
                            res.send record
                        else
                            res.send 'Access denied.'
                    else
                        res.send "Invalid article."
                catch e
                    next e)()    
                     

            
    addComment: (req, res, next, collection) =>        
        @attachUser arguments, => 
            contentType = collection.settings?.comments?.contentType ? 'text'
            if contentType is 'text'
                (Q.async =>
                    try
                        record = yield models.Record.getById(req.params('record'), { user: req.user }, db)
                        comment = new models.Comment()
                        comment.createdBy = req.user
                        comment.collection = collection.stub
                        comment.itemid = record._id.toString()
                        comment.data = req.body('data')
                        comment = yield comment.save({ user: req.user }, db)
                        res.send comment
                    catch e
                        next e)()                
            else
                next new Error 'Unsupported Comment Type'



    #Admin Features
    admin_update: (req, res, next) =>
        @ensureSession [req, res, next], =>
            if @isAdmin(req.user)
                (Q.async =>
                    try
                        record = yield models.Record.getById(req.params('id'), { user: req.user }, db)
                        if record 
                            if req.body('meta')
                                record = yield record.addMetaList req.body('meta').split(',')
                            res.send record
                        else
                            next new Error "Record not found"
                    catch e
                        next e)()
            else
                next new Error "Access denied"


exports.Records = Records

