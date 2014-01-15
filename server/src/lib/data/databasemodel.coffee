thunkify = require 'thunkify'
databaseModule = require('./database').Database
utils = require('../utils')
BaseModel = require('./basemodel').BaseModel

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)



    @get: (params, context, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(modelTypeDefinition.collection, params)
        if result then yield @constructModel(result, modelTypeDefinition, context, db)
                


    @getAll: (params, context, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        cursor = yield db.find(modelTypeDefinition.collection, params)
        items = yield thunkify(cursor.toArray).call cursor
        if items.length
            (yield @constructModel(item, modelTypeDefinition, context, db) for item in items)
        else
            []
                    

    
    @find: (params, fnCursor, context, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        cursor = yield db.find(modelTypeDefinition.collection, params)
        fnCursor cursor
        items = yield thunkify(cursor.toArray).call cursor
        if items.length
            (yield @constructModel(item, modelTypeDefinition, context, db) for item in items)
        else
            []            



    @getCursor: (params, context, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        yield db.find modelTypeDefinition.collection, params


           
    @getById: (id, context, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(modelTypeDefinition.collection, { _id: databaseModule.ObjectId(id) })
        if result then yield @constructModel(result, modelTypeDefinition, context, db)
            
            
            
    @destroyAll: (params, db) ->*
        modelTypeDefinition = yield @getTypeDefinition()
        if modelTypeDefinition.canDestroyAll?(params)
            yield db.remove(modelTypeDefinition.collection, params)
        else
            throw new Error "Call to destroyAll must pass safety checks on params."
            
            
        
    attachContextAndDb = (model, context, db) ->
        if model instanceof DatabaseModel
            model.__context = context
            model.__db = db
        
        
        
    detachContextAndDb = (model) ->
        if model instanceof DatabaseModel
            model.__context = undefined
            model.__db = undefined


    makeResult = (obj, fnConstructor, context, db) ->*
        result = yield fnConstructor(obj, context, db)
        attachContextAndDb(result, context, db)
        result
        
    
    @constructModel: (obj, modelTypeDefinition, context, db) ->*
        if modelTypeDefinition.discriminator
            modelTypeDefinition = yield (yield modelTypeDefinition.discriminator obj).getTypeDefinition()
            
        result = yield @_constructModel_impl(obj, modelTypeDefinition, context, db)

        if modelTypeDefinition.trackChanges
            clone = utils.deepCloneObject(obj)
            original = yield @_constructModel_impl(clone, modelTypeDefinition, context, db)
            result.getOriginalModel = ->
                original
        
        result
        
        
    
    @_constructModel_impl: (obj, modelTypeDefinition, context, db) ->*
        if modelTypeDefinition.customConstructor
            fnCtor = (_o, _ctx, _db) ->* yield modelTypeDefinition.customConstructor _o, _ctx, _db
            yield makeResult obj, fnCtor, context, db
        else
            result = yield @constructModelFields(obj, modelTypeDefinition.fields, context, db)

            fnCtor = (_o, _ctx, _db) ->* new modelTypeDefinition.type _o, _ctx, _db
            yield makeResult result, fnCtor, context, db                
                

    
    @constructModelFields: (obj, fields, context, db) ->*
        result = {}
        typeUtils = @getTypeUtils()        
    
        for name, fieldDef of fields
               
            value = obj[name]

            if typeUtils.isUserDefinedType fieldDef.type
                if value
                    result[name] = yield @constructModel value, yield fieldDef.ctor.getTypeDefinition(), context, db
            else
                if value?
                    if fieldDef.type is 'array'
                        arr = []
                        if typeUtils.isUserDefinedType fieldDef.contents.type
                            for item in value
                                arr.push yield @constructModel item, yield fieldDef.contents.ctor.getTypeDefinition(), context, db
                        else
                            arr = value
                        result[name] = arr
                    else
                        result[name] = value    
        
        if obj._id
            result._id = obj._id
    
        result
        
    
    
    create: =>
        if not @_id
            @save.apply @, arguments
        else
            throw new Error "Cannot create. @_id is not empty."
        
    
    
    save: (context, db) =>*
    
        context ?= @__context
        db ?= @__db
        detachContextAndDb @

        modelTypeDefinition = yield @getTypeDefinition()

        for fieldName, def of modelTypeDefinition.fields
            if def.autoGenerated
                switch def.event
                    when 'created'
                        if not @_id?
                            @[fieldName] = Date.now()    
                    when 'updated'
                        @[fieldName] = Date.now()                            
        
        errors = yield @validate()

        if not errors.length

            if @_id and (modelTypeDefinition.concurrency is 'optimistic' or not modelTypeDefinition.concurrency)
                _item = yield @constructor.getById(@_id, context, db)
                if _item.__updateTimestamp isnt @__updateTimestamp
                    throw new Error "Update timestamp mismatch. Was #{_item.__updateTimestamp} in saved, #{@__updateTimestamp} in new."

            @__updateTimestamp = Date.now()                
            @__shard = if modelTypeDefinition.generateShard? then modelTypeDefinition.generateShard(@) else "1"

            if not @_id
                if modelTypeDefinition.logging?.onInsert
                    event = {
                        type: modelTypeDefinition.logging.onInsert,
                        data: @
                    }
                    db.insert('events', event)                            
                result = yield db.insert(modelTypeDefinition.collection, @)
                result = yield @constructor.constructModel(result, modelTypeDefinition, context, db)
            else
                if modelTypeDefinition.logging?.onUpdate
                    event = {
                        type: modelTypeDefinition.logging.onUpdate,
                        data: @
                    }
                    db.insert('events', event)
                yield db.update(modelTypeDefinition.collection, { @_id }, @)
                attachContextAndDb @, context, db
                result = @

            return result              
                                  
        else
            @onError errors, modelTypeDefinition

    
    
    destroy: (context, db) =>*
        context ?= @__context
        db ?= @__db
        if not context or not db
            throw new Error "Invalid context or db"

        modelTypeDefinition = yield @getTypeDefinition()
        db.remove modelTypeDefinition.collection, { _id: @_id }


    
    associations: (name, context, db) =>*
        { context, db } = @getContext context, db
        desc = yield @getTypeDefinition()
        
        assoc = desc.associations[name]
        typeUtils = @constructor.getTypeUtils()
        ctor = typeUtils.resolveUserDefinedType assoc.type
        params = {}
        for k, v of assoc.key
            params[v] = if k is '_id' then @_id.toString() else @[k]
        if assoc.multiplicity is "many"
            yield ctor.getAll params, context, db
        else
            yield ctor.get params, context, db
        


    onError: (errors, modelTypeDefinition) =>
        if @_id
            details = "Invalid record with id #{@_id} in #{modelTypeDefinition.collection}.\n"
        else
            details = "Validation failed while creating a new record in #{modelTypeDefinition.collection}.\n"
        
        details += "#{errors.length} errors generated at #{Date().toString('yyyy-MM-dd')}"
        details = "#{details}: #{errors.join(', ')}"
        
        error = new Error("Model failed validation: #{details}")
        error.details = details  
        throw error            
        


    bindContext: (@__context, @__db) =>



    getContext: (context, db) =>
        { context: context ? @__context, db: db ? @__db }


exports.DatabaseModel = DatabaseModel

