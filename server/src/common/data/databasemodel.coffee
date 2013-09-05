databaseModule = require('./database').Database
utils = require('../utils')
BaseModel = require('./basemodel').BaseModel
ValidationError = require('./basemodel').ValidationError
Q = require('../q')

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)



    @get: (params, context, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>
            result = yield db.findOne(modelDescription.collection, params)
            if result then @constructModel(result, modelDescription, context, db)
        )()
                


    @getAll: (params, context, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>
            cursor = yield db.find(modelDescription.collection, params)
            items = yield Q.nfcall cursor.toArray.bind(cursor)
            if items.length
                (@constructModel(item, modelDescription, context, db) for item in items)
            else
                []
        )()
                    

    
    @find: (params, fnCursor, context, db) ->
        modelDescription = @getModelDescription()
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
        modelDescription = @getModelDescription()
        (Q.async =>
            yield db.find modelDescription.collection, params
        )()


           
    @getById: (id, context, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>
            result = yield db.findOne(modelDescription.collection, { _id: databaseModule.ObjectId(id) })
            if result then @constructModel(result, modelDescription, context, db)
        )()
            
            
            
    @destroyAll: (params, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>            
            if modelDescription.validateMultiRecordOperationParams(params)
                yield db.remove(modelDescription.collection, params)
            else
                throw new Error "Call to destroyAll must pass safety checks on params."
        )()
            
            
        
    attachContextAndDb = (model, context, db) ->
        if model instanceof DatabaseModel
            if context
                model.__context = context
            if db
                model.__db = db
            if not context or not db
                throw new Error "Invalid context or db"
        
        
        
    detachContextAndDb = (model) ->
        if model instanceof DatabaseModel
            context = model.__context
            db = model.__db
            model.__context = undefined
            model.__db = undefined
        
    
    makeResult = (obj, fnConstructor, modelDescription, context, db) ->
        result = fnConstructor(obj)
        if modelDescription.trackChanges
            original = fnConstructor(obj)
            result.getOriginalValue = ->
                original
        attachContextAndDb(result, context, db)
        result
    
    
    @constructModel: (obj, modelDescription, context, db) ->    
        if modelDescription.customConstructor
            makeResult obj, ((o) -> modelDescription.customConstructor o), modelDescription, context, db
        else           
            if modelDescription.hasOwnProperty('discriminator')
                @constructModel(obj, @getModelDescription(modelDescription.discriminator obj), context, db)
            else
                result = {}
                for name, field of modelDescription.fields
                    value = obj[name]
                    
                    fieldDef = @getFullFieldDefinition field
                    if @isCustomClass fieldDef.type
                        if value
                            result[name] = @constructModel value, @getModelDescription(fieldDef.type), context, db
                    else
                        if value
                            if fieldDef.type is 'array'
                                arr = []
                                contentType = @getFullFieldDefinition fieldDef.contents
                                if @isCustomClass contentType.type
                                    for item in value
                                        arr.push @constructModel item, @getModelDescription(contentType.type), context, db
                                else
                                    arr = value
                                result[name] = arr
                            else
                                result[name] = value    
                
                if obj._id
                    result._id = obj._id

                makeResult result, ((o) -> new modelDescription.type o), modelDescription, context, db                
                
        
    
    save: (context, db) =>
        (Q.async =>
            context ?= @__context
            db ?= @__db
            detachContextAndDb @
            if not context or not db
                throw new Error "Invalid context or db"
        
            modelDescription = @constructor.getModelDescription()

            original = @__original
            @__original = undefined
            
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

                if @_id and modelDescription.concurrency is 'optimistic'
                    _item = yield @constructor.getById(@_id, context, db)
                    if _item.__updateTimestamp isnt @__updateTimestamp
                        throw new Error "Update timestamp mismatch. Was #{_item.__updateTimestamp} in saved, #{@__updateTimestamp} in new."

                @__updateTimestamp = Date.now()                
                @__shard = if modelDescription.generateShard? then modelDescription.generateShard(@) else "1"

                if not @_id?
                    if modelDescription.logging?.onInsert
                        event = {
                            type: modelDescription.logging.onInsert,
                            data: @
                        }
                        db.insert('events', event)                            
                    result = yield db.insert(modelDescription.collection, @)
                    result = DatabaseModel.constructModel(result, modelDescription, context, db)
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
                if @_id
                    msg = "Invalid record with id #{@_id} in #{modelDescription.collection}.\n"
                else
                    msg = "Validation failed while creating a new record in #{modelDescription.collection}.\n"
                
                msg += "#{errors.length} errors generated at #{Date().toString('yyyy-MM-dd')}\n"
                for e in errors
                    msg += e + "\n"

                throw new ValidationError 'Model failed validation', msg
        )()

    
    
    destroy: (context, db) =>
        context ?= @__context
        db ?= @__db
        if not context or not db
            throw new Error "Invalid context or db"

        modelDescription = @constructor.getModelDescription()
        db.remove modelDescription.collection, { _id: @_id }



exports.DatabaseModel = DatabaseModel

