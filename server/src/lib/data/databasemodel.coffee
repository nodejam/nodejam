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
        typeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(typeDefinition.collection, params)
        if result then yield @constructModel(result, typeDefinition, context, db)
                


    @getAll: (params, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        cursor = yield db.find(typeDefinition.collection, params)
        items = yield thunkify(cursor.toArray).call cursor
        if items.length
            (yield @constructModel(item, typeDefinition, context, db) for item in items)
        else
            []
                    

    
    @find: (params, fnCursor, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        cursor = yield db.find(typeDefinition.collection, params)
        fnCursor cursor
        items = yield thunkify(cursor.toArray).call cursor
        if items.length
            (yield @constructModel(item, typeDefinition, context, db) for item in items)
        else
            []            



    @getCursor: (params, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        yield db.find typeDefinition.collection, params


           
    @getById: (id, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(typeDefinition.collection, { _id: databaseModule.ObjectId(id) })
        if result then yield @constructModel(result, typeDefinition, context, db)
            
            
            
    @destroyAll: (params, db) ->*
        typeDefinition = yield @getTypeDefinition()
        if typeDefinition.canDestroyAll?(params)
            yield db.remove(typeDefinition.collection, params)
        else
            throw new Error "Call to destroyAll must pass safety checks on params."
            
            
        
    attachSystemFields = (model, context, db) ->
        if model instanceof DatabaseModel
            model.__context = context
            model.__db = db
        
        
        
    detachSystemFields = (model) ->
        if model instanceof DatabaseModel
            model.__context = undefined
            model.__db = undefined


    makeResult = (obj, fnConstructor, context, db) ->*
        result = yield fnConstructor(obj, context, db)
        attachSystemFields(result, context, db)
        result
        
    
    
    @constructModel: (obj, typeDefinition, context, db) ->*
        if typeDefinition.discriminator
            effectiveTypeDef = yield typeDefinition.discriminator obj
        else
            effectiveTypeDef = typeDefinition
            
        result = yield @_constructModel_impl(obj, effectiveTypeDef, context, db)
        
        if effectiveTypeDef.trackChanges
            clone = utils.deepCloneObject(obj)
            original = yield @_constructModel_impl(clone, effectiveTypeDef, context, db)
            result.getOriginalModel = ->
                original
        
        if effectiveTypeDef isnt typeDefinition
            result.getTypeDefinition = original.getTypeDefinition = ->* effectiveTypeDef
        
        result
        
        
    
    @_constructModel_impl: (obj, typeDefinition, context, db) ->*
        if typeDefinition.customConstructor
            fnCtor = (_o, _ctx, _db) ->* yield typeDefinition.customConstructor _o, _ctx, _db
            yield makeResult obj, fnCtor, context, db
        else
            result = yield @constructModelFields obj, typeDefinition.schema.properties, context, db

            fnCtor = (_o, _ctx, _db) ->* new typeDefinition.ctor _o, _ctx, _db
            yield makeResult result, fnCtor, context, db                
                

    
    @constructModelFields: (obj, fields, context, db) ->*
        result = {}
        typeUtils = @getTypeUtils()
    
        for name, def of fields
               
            value = obj[name]

            if typeUtils.isPrimitiveType(def.type)
                if value?
                    if def.type is 'array'
                        arr = []
                        if def.items.typeDefinition
                            for item in value
                                arr.push yield @constructModel item, def.items.typeDefinition
                        else
                            arr = value
                        result[name] = arr
                    else
                        result[name] = value
            else
                if def.typeDefinition #Known type definition
                    if value
                        result[name] = yield @constructModel value, def.typeDefinition
                else #Object of any structure
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
        detachSystemFields @

        typeDefinition = yield @getTypeDefinition()

        if typeDefinition.autoGenerated
            for fieldName, def of typeDefinition.autoGenerated
                switch def.event
                    when 'created'
                        if not @_id?
                            @[fieldName] = Date.now()    
                    when 'updated'
                        @[fieldName] = Date.now()                            
        
        errors = yield @validate()

        if not errors.length

            if @_id and (typeDefinition.concurrency is 'optimistic' or not typeDefinition.concurrency)
                _item = yield @constructor.getById(@_id, context, db)
                if _item.__updateTimestamp isnt @__updateTimestamp
                    throw new Error "Update timestamp mismatch. Was #{_item.__updateTimestamp} in saved, #{@__updateTimestamp} in new."

            @__updateTimestamp = Date.now()                
            @__shard = if typeDefinition.generateShard? then typeDefinition.generateShard(@) else "1"

            if not @_id
                if typeDefinition.logging?.onInsert
                    event = {
                        type: typeDefinition.logging.onInsert,
                        data: @
                    }
                    db.insert('events', event)                            
                result = yield db.insert(typeDefinition.collection, @)
                result = yield @constructor.constructModel(result, typeDefinition, context, db)
            else
                if typeDefinition.logging?.onUpdate
                    event = {
                        type: typeDefinition.logging.onUpdate,
                        data: @
                    }
                    db.insert('events', event)
                yield db.update(typeDefinition.collection, { @_id }, @)
                attachSystemFields @, context, db
                result = @

            return result              
                                  
        else
            if @_id
                details = "Invalid record with id #{@_id} in #{typeDefinition.collection}.\n"
            else
                details = "Validation failed while creating a new record in #{typeDefinition.collection}.\n"
            
            details += "#{errors.length} errors generated at #{Date().toString('yyyy-MM-dd')}"
            details = "#{details}: #{errors.join(', ')}"
            
            error = new Error("Model failed validation: #{details}")
            error.details = details  
            throw error    

    
    
    destroy: (context, db) =>*
        context ?= @__context
        db ?= @__db
        if not context or not db
            throw new Error "Invalid context or db"

        typeDefinition = yield @getTypeDefinition()
        db.remove typeDefinition.collection, { _id: @_id }


    
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
        
    

    bindContext: (@__context, @__db) =>



    getContext: (context, db) =>
        { context: context ? @__context, db: db ? @__db }


exports.DatabaseModel = DatabaseModel

