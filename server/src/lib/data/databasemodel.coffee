databaseModule = require('./database').Database
utils = require('../utils')
BaseModel = require('./basemodel').BaseModel
Q = require('../q')

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)



    @get: (params, context, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>
            result = yield db.findOne(modelDescription.collection, params)
            if result then @constructModel(result, modelDescription, context, db)
        )()
                


    @getAll: (params, context, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>
            cursor = yield db.find(modelDescription.collection, params)
            items = yield Q.nfcall cursor.toArray.bind(cursor)
            if items.length
                (@constructModel(item, modelDescription, context, db) for item in items)
            else
                []
        )()
                    

    
    @find: (params, fnCursor, context, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>
            cursor = yield db.find(modelDescription.collection, params)
            fnCursor cursor
            items = yield Q.nfcall cursor.toArray.bind(cursor)
            if items.length
                (@constructModel(item, modelDescription, context, db) for item in items)
            else
                []            
        )()



    @getCursor: (params, context, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>
            yield db.find modelDescription.collection, params
        )()


           
    @getById: (id, context, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>
            result = yield db.findOne(modelDescription.collection, { _id: databaseModule.ObjectId(id) })
            if result then @constructModel(result, modelDescription, context, db)
        )()
            
            
            
    @destroyAll: (params, db) ->
        modelDescription = @getTypeDefinition()
        (Q.async =>            
            if modelDescription.canDestroyAll?(params)
                yield db.remove(modelDescription.collection, params)
            else
                throw new Error "Call to destroyAll must pass safety checks on params."
        )()
            
            
        
    attachContextAndDb = (model, context, db) ->
        if model instanceof DatabaseModel
            model.__context = context
            model.__db = db
        
        
        
    detachContextAndDb = (model) ->
        if model instanceof DatabaseModel
            model.__context = undefined
            model.__db = undefined



    @constructModel: (obj, modelDescription, context, db) ->
        if modelDescription.discriminator
            modelDescription = modelDescription.discriminator(obj).getTypeDefinition()
            
        result = @constructModelImpl(obj, modelDescription, context, db)

        if modelDescription.trackChanges
            clone = utils.deepCloneObject(obj)
            original = @constructModelImpl(clone, modelDescription, context, db)
            result.getOriginalModel = ->
                original
        
        result
        
        
    
    makeResult = (obj, fnConstructor, context, db) ->
        result = fnConstructor(obj)
        attachContextAndDb(result, context, db)
        result
        
    
    
    @constructModelImpl: (obj, modelDescription, context, db) ->
        typeUtils = @getTypeUtils()        
        
        if modelDescription.customConstructor
            makeResult obj, ((o) -> modelDescription.customConstructor o), context, db
        else           
            result = {}
            for name, fieldDef of modelDescription.fields
                   
                value = obj[name]

                if typeUtils.isUserDefinedType fieldDef.type
                    if value
                        result[name] = @constructModel value, fieldDef.ctor.getTypeDefinition(), context, db
                else
                    if value?
                        if fieldDef.type is 'array'
                            arr = []
                            if typeUtils.isUserDefinedType fieldDef.contents.type
                                for item in value
                                    arr.push @constructModel item, fieldDef.contents.ctor.getTypeDefinition(), context, db
                            else
                                arr = value
                            result[name] = arr
                        else
                            result[name] = value    
            
            if obj._id
                result._id = obj._id

            makeResult result, ((o) -> new modelDescription.type o), context, db                
                
    
    
    create: =>
        if not @_id
            @save.apply @, arguments
        else
            throw new Error "Cannot create. @_id is not empty."
        
    
    
    save: (context, db) =>
        (Q.async =>
            context ?= @__context
            db ?= @__db
            detachContextAndDb @
        
            modelDescription = @getTypeDefinition()

            for fieldName, def of modelDescription.fields
                if def.autoGenerated
                    switch def.event
                        when 'created'
                            if not @_id?
                                @[fieldName] = Date.now()    
                        when 'updated'
                            @[fieldName] = Date.now()                            
            
            
            errors = @validate()

            if not errors.length

                if @_id and (modelDescription.concurrency is 'optimistic' or not modelDescription.concurrency)
                    _item = yield @constructor.getById(@_id, context, db)
                    if _item.__updateTimestamp isnt @__updateTimestamp
                        throw new Error "Update timestamp mismatch. Was #{_item.__updateTimestamp} in saved, #{@__updateTimestamp} in new."

                @__updateTimestamp = Date.now()                
                @__shard = if modelDescription.generateShard? then modelDescription.generateShard(@) else "1"

                if not @_id
                    if modelDescription.logging?.onInsert
                        event = {
                            type: modelDescription.logging.onInsert,
                            data: @
                        }
                        db.insert('events', event)                            
                    result = yield db.insert(modelDescription.collection, @)
                    result = @constructor.constructModel(result, modelDescription, context, db)
                else
                    if modelDescription.logging?.onUpdate
                        event = {
                            type: modelDescription.logging.onUpdate,
                            data: @
                        }
                        db.insert('events', event)
                    yield db.update(modelDescription.collection, { @_id }, @)
                    attachContextAndDb @, context, db
                    result = @

                return result              
                                      
            else
                @onError errors, modelDescription
        )()

    
    
    destroy: (context, db) =>
        context ?= @__context
        db ?= @__db
        if not context or not db
            throw new Error "Invalid context or db"

        modelDescription = @getTypeDefinition()
        db.remove modelDescription.collection, { _id: @_id }


    
    associations: (name, context, db) =>
        { context, db } = @getContext context, db
        desc = @getTypeDefinition()
        
        assoc = desc.associations[name]
        typeUtils = @constructor.getTypeUtils()
        ctor = typeUtils.resolveType assoc.type
        (Q.async =>            
            params = {}
            for k, v of assoc.key
                params[v] = if k is '_id' then @_id.toString() else @[k]
            if assoc.multiplicity is "many"
                yield ctor.getAll params, context, db
            else
                yield ctor.get params, context, db
        )()             
        


    onError: (errors, modelDescription) =>
        if @_id
            details = "Invalid record with id #{@_id} in #{modelDescription.collection}.\n"
        else
            details = "Validation failed while creating a new record in #{modelDescription.collection}.\n"
        
        details += "#{errors.length} errors generated at #{Date().toString('yyyy-MM-dd')}\n"
        for e in errors
            details += e + "\n"
        
        error = new Error('Model failed validation')
        error.details = details                
        throw error            
        


    bindContext: (@__context, @__db) =>



    getContext: (context, db) =>
        { context: context ? @__context, db: db ? @__db }


exports.DatabaseModel = DatabaseModel

