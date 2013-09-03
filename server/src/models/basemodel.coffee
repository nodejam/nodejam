databaseModule = require('../common/database').Database
utils = require('../common/utils')
Q = require('../common/q')

class BaseModel

    class ValidationError extends Error        
        constructor: (@message, @details) ->
            Error.captureStackTrace @, ValidationError
            

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)


           
    @get: (params, context, db) ->
        modelDescription = @getModelDescription()
        db.findOne(modelDescription.collection, params)
            .then (result) =>
                if result then @constructModel(result, modelDescription)
                


    @getAll: (params, context, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>
            cursor = yield db.find(modelDescription.collection, params)
            items = yield Q.nfcall cursor.toArray.bind(cursor)
            if items.length
                (@constructModel(item, modelDescription) for item in items)
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
                (@constructModel(item, modelDescription) for item in items)
            else
                []            
        )()



    @getCursor: (params, context, db) ->
        modelDescription = @getModelDescription()
        db.find modelDescription.collection, params


           
    @getById: (id, context, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>
            result = yield db.findOne(modelDescription.collection, { _id: databaseModule.ObjectId(id) })
            if result then @constructModel(result, modelDescription)
        )()
            
            
            
    @destroyAll: (params, db) ->
        modelDescription = @getModelDescription()
        (Q.async =>            
            if modelDescription.validateMultiRecordOperationParams(params)
                yield db.remove(modelDescription.collection, params)
            else
                throw new Error "Call to destroyAll must pass safety checks on params."
        )()

            
            
    @mergeModelDescription: (child, parent) ->
        fields = utils.clone(parent.fields)   
        for k,v of child.fields
            fields[k] = v
        modelDescription = utils.clone(parent)
        for k,v of child
            if k isnt 'fields'
                modelDescription[k] = v
        modelDescription.fields = fields
        modelDescription
                
                
    
    @getModelDescription: (model = @) ->
        try
            modelDescription = model.describeModel()
            modelDescription.validateMultiRecordOperationParams ?= (params) -> 
                false
            modelDescription
        catch e
            utils.dumpError e
        
    
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        
        
        
        
    @constructModel: (obj, modelDescription) ->
        if modelDescription.customConstructor
            modelDescription.customConstructor obj
        else           
            if modelDescription.hasOwnProperty('discriminator')
                @constructModel obj, @getModelDescription(modelDescription.discriminator(obj))
            else
                result = {}
                for name, field of modelDescription.fields
                    value = obj[name]
                    
                    fieldDef = @getFullFieldDefinition field
                    if @isCustomClass fieldDef.type
                        if value
                            result[name] = @constructModel value, @getModelDescription(fieldDef.type)
                    else
                        if value
                            if fieldDef.type is 'array'
                                arr = []
                                contentType = @getFullFieldDefinition fieldDef.contents
                                if @isCustomClass contentType.type
                                    for item in value
                                        arr.push @constructModel item, @getModelDescription(contentType.type)
                                else
                                    arr = value
                                result[name] = arr
                            else
                                result[name] = value    
                
                if obj._id
                    result._id = obj._id

                new modelDescription.type result
                
                
                
    @isCustomClass: (type) ->
        ['string', 'number', 'boolean', 'object', 'array', ''].indexOf(type) is -1                



    @getFullFieldDefinition: (def) ->
        #Convert short hands to full definitions.
        #eg: 'string' means { type: 'string', required: true }
        if typeof(def) isnt "object"
            fieldDef = {
                type: def,
                required: true
            }
        else 
            fieldDef = def

        if fieldDef.autoGenerated and (fieldDef.event is 'created' or fieldDef.event is 'updated')
            fieldDef.type = 'number'
            fieldDef.required = true

        fieldDef.required ?= true
        fieldDef.type ?= ''
        
        fieldDef
        
    
    
    @getModels: (path = './') =>
        if not @__models
            @__models = require path
        @__models
        
        
        
    getModels: (path = './') =>
        @constructor.getModels path
        
        
    
    save: (context, db) =>    
        (Q.async =>

            modelDescription = @constructor.getModelDescription()
            
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
                    if _item._updateTimestamp isnt @_updateTimestamp
                        throw new Error "Update timestamp mismatch. Was #{_item._updateTimestamp} in saved, #{@_updateTimestamp} in new."

                @_updateTimestamp = Date.now()                
                @_shard = if modelDescription.generateShard? then modelDescription.generateShard(@) else "1"

                if not @_id?
                    if modelDescription.logging?.isLogged
                        event = {}
                        event.type = modelDescription.logging.onInsert
                        event.data = this
                        db.insert('events', event)
                    
                    yield db.insert(modelDescription.collection, @)
                else
                    yield db.update(modelDescription.collection, { _id: @_id }, @)
            
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

    
    
    validate: (modelDescription = @constructor.getModelDescription()) =>    
        errors = []
        
        if not modelDescription.useCustomValidationOnly
            for fieldName, def of modelDescription.fields                
                BaseModel.addError errors, fieldName, @validateField(@[fieldName], fieldName, def)

            if modelDescription.validate
                customValidationResults = modelDescription.validate.call @                    
                return if customValidationResults?.length then errors.concat customValidationResults else errors
            else
                return errors
        else
            if modelDescription.validate
                customValidationResults = modelDescription.validate.call @, modelDescription
                return if customValidationResults?.length then customValidationResults else []
            else
                return []
                        
            

    validateField: (value, fieldName, def) =>
        errors = []

        if not def.useCustomValidationOnly                
            fieldDef = BaseModel.getFullFieldDefinition(def)

            if fieldDef.required and not value?
                errors.push "#{fieldName} is #{JSON.stringify value}"
                errors.push "#{fieldName} is required."
            
            #Check types.       
            if value
                if fieldDef.type is 'array'
                    for item in value                        
                        BaseModel.addError errors, fieldName, @validateField(item, "[#{fieldName} item]", fieldDef.contents)
                else
                    #If it is a custom class or a primitive
                    if fieldDef.type isnt '' and fieldDef.type isnt 'object'                        
                        if (BaseModel.isCustomClass(fieldDef.type) and not (value instanceof fieldDef.type)) or (not BaseModel.isCustomClass(fieldDef.type) and typeof(value) isnt fieldDef.type)
                            errors.push "#{fieldName} is #{JSON.stringify value}"
                            errors.push "#{fieldName} should be a #{fieldDef.type}."

                    if BaseModel.isCustomClass(fieldDef.type) and value.validate()
                        errors = errors.concat value.validate()
                    else
                        #We should also check for objects inside object. (ie, do we have fields inside the fieldDef?)
                        if fieldDef.fields
                            errors =  errors.concat @validate.call value, fieldDef

        if value and fieldDef.validate
            BaseModel.addError errors, fieldName, fieldDef.validate.call(@)
            
        errors            
        

    
    destroy: (context, db) =>
        modelDescription = @constructor.getModelDescription()
        db.remove modelDescription.collection, { _id: @_id }


    
    @addError: (list, fieldName, error) ->
        if error is true
            return list
        if error is false
            list.push "#{fieldName} is invalid."
            return list
        if error instanceof Array
            if error.length > 0
                for item in error
                    BaseModel.addError list, fieldName, item
            return list
        if error
            list.push error
            return list


exports.BaseModel = BaseModel

