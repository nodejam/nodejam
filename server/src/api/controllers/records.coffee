conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
typeUtil = require '../../common/data/typeutil'
Controller = require('./controller').Controller
controllers = require './'
Q = require('../../common/q')

class Records extends Controller


    create: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get { stub: req.params.collection, network: req.network.stub }, { user: req.user }, db
                    type = models.Record.getTypeDefinition().discriminator req.body        
                
                    record = new type()
                    record.type = req.body.type
                    record.createdBy = req.user
                    record.rating = 0

                    if req.body.publish is 'true'
                        record.state = 'published'
                    else
                        record.state = 'draft'
                    record.savedAt = Date.now()

                    for fieldName, def of type.getTypeDefinition(type, false).fields
                        def = typeUtil.getFullTypeDefinition def
                        
                        if req.body[fieldName]
                            switch def.type
                                when "string"                        
                                    record[fieldName] = req.body[fieldName]
                        else
                            if def.default
                                if typeof def.default is "function"
                                    record[fieldName] = def.default.call record, req.body
                                else
                                    record[fieldName] = def.default
                    
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
                    collection = yield models.Collection.get { stub: req.params.collection, network: req.network.stub }, { user: req.user }, db
                    type = models.Record.getTypeDefinition().discriminator req.body        
                    record = yield type.getById(req.params.record, { user: req.user }, db)
                    
                    if record
                        if record.createdBy.id is req.user.id or @isAdmin(req.user)
                            record.savedAt ?= Date.now()
                            
                            #Add update code here...
                            
                            record = yield record.save()                            
                            res.send record

                        else
                            res.send 'Access denied.'
                    else
                        res.send 'Invalid record.'
                catch e
                    next e)()    


                
    remove: (req, res, next) =>
        @ensureSession arguments, => 
            (Q.async =>
                try
                    record = yield models.Record.getById(req.params.record, { user: req.user }, db)
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
                        record = yield models.Record.getById(req.params.record, { user: req.user }, db)
                        comment = new models.Comment()
                        comment.createdBy = req.user
                        comment.collection = collection.stub
                        comment.itemid = record._id.toString()
                        comment.data = req.body.data
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
                        record = yield models.Record.getById(req.params.id, { user: req.user }, db)
                        if record 
                            if req.body.meta
                                record = yield record.addMetaList req.body.meta.split(',')
                            res.send record
                        else
                            next new Error "Record not found"
                    catch e
                        next e)()
            else
                next new Error "Access denied"


exports.Records = Records

