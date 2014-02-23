thunkify = require 'thunkify'
utils = require '../utils'
BaseModel = require './basemodel'

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @get: (query, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(typeDefinition, query)
        if result then yield @constructModel(result, typeDefinition, context, db)
                


    @getAll: (query, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        items = yield db.find(typeDefinition, query)
        if items.length
            (yield @constructModel(item, typeDefinition, context, db) for item in items)
        else
            []
                    

    
    @find: (query, options, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        items = yield db.find typeDefinition, query, options
        if items.length
            (yield @constructModel(item, typeDefinition, context, db) for item in items)
        else
            []            



    @findOne: (query, options, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        result = yield db.findOne typeDefinition, query, options
        if result then yield @constructModel(result, typeDefinition, context, db)



    @count: (query, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        yield db.count typeDefinition, query



    @getById: (id, context, db) ->*
        typeDefinition = yield @getTypeDefinition()
        result = yield db.findOne(typeDefinition, { _id: db.ObjectId(id) })
        if result then yield @constructModel(result, typeDefinition, context, db)
            


    @destroyAll: (query, db) ->*
        typeDefinition = yield @getTypeDefinition()
        if typeDefinition.canDestroyAll?(query)
            yield db.remove(typeDefinition, query)
        else
            throw new Error "Call to destroyAll must pass safety checks on query."
            
            
        
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

            fnCtor = (_o, _ctx, _db) ->*
                if typeDefinition.ctor then new typeDefinition.ctor _o, _ctx, _db else _o
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
                                arr.push yield @constructModel item, def.items.typeDefinition, context, db
                        else
                            arr = value
                        result[name] = arr
                    else
                        result[name] = value
            else
                if def.typeDefinition #Known type definition
                    if value
                        result[name] = yield @constructModel value, def.typeDefinition, context, db
                else #Object of any structure
                    result[name] = value
        
        if obj._id
            result._id = obj._id
    
        result
        
    
    
    create: =>
        if not @_id
            @save.apply @, arguments
        else
            throw new Error "Cannot create. @_id is not empty"
        
    
    
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
                result = yield db.insert(typeDefinition, @)
                result = yield @constructor.constructModel(result, typeDefinition, context, db)
            else
                if typeDefinition.logging?.onUpdate
                    event = {
                        type: typeDefinition.logging.onUpdate,
                        data: @
                    }
                    db.insert('events', event)
                yield db.update(typeDefinition, { @_id }, @)
                attachSystemFields @, context, db
                result = @

            return result              
                                  
        else
            if @_id
                details = "Invalid record with id #{@_id} in #{typeDefinition}.\n"
            else
                details = "Validation failed while creating a new record in #{typeDefinition}.\n"
            
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
        db.remove typeDefinition, { _id: @_id }


    
    link: (name, context, db) =>*
        { context, db } = @getContext context, db

        typeUtils = @constructor.getTypeUtils()
        typeDef = yield @getTypeDefinition()
        link = typeDef.links[name]
        otherTypeDef = yield typeUtils.getTypeDefinition(link.type)        
        
        if link.key
            #This is the child record
            #make sure there is a link back
            switch typeDef.schema.properties[link.key].type
                when 'string'
                    if @[link.key]
                        yield otherTypeDef.ctor.getById @[link.key], context, db    
                when 'array'
                    throw new Error "Array keys are not implemented"
                    
        else if link.field
            #Parent record
            switch otherTypeDef.schema.properties[link.field].type
                when 'string'
                    params = {}
                    params["#{link.field}"] = @_id.toString()
                    result = yield otherTypeDef.ctor.getAll params, context, db

                    if link.multiplicity is "one"
                        if result.length then result[0]
                    else
                        result
                when 'array'
                    throw new Error "Array keys are not implemented"
                                
        else
            throw new Error "Invalid link #{name} in #{typeDef.name}"
        
    

    bindContext: (@__context, @__db) =>



    getContext: (context, db) =>
        { context: context ? @__context, db: db ? @__db }


module.exports = DatabaseModel

