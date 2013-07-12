databaseModule = require('../common/database').Database
utils = require('../common/utils')
AppError = require('../common/apperror').AppError

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)


           
    @get: (params, context, db, cb) ->
        modelDescription = @getModelDescription()
        db.findOne modelDescription.collection, params, (err, result) =>
            cb err, if result then @constructModel(result, modelDescription)



    @getAll: (params, context, db, cb) ->
        modelDescription = @getModelDescription()
        db.find modelDescription.collection, params, (err, cursor) =>
            cursor.toArray (err, items) =>
                cb err, if items?.length then (@constructModel(item, modelDescription) for item in items) else []


    
    @find: (params, fnCursor, context, db, cb) ->
        modelDescription = @getModelDescription()
        db.find modelDescription.collection, params, (err, cursor) =>
            fnCursor cursor
            cursor.toArray (err, items) =>
                cb err, if items?.length then (@constructModel(item, modelDescription) for item in items) else []    



    @getCursor: (params, context, db, cb) ->
        modelDescription = @getModelDescription()
        db.find modelDescription.collection, params, cb


           
    @getById: (id, context, db, cb) ->
        modelDescription = @getModelDescription()
        db.findOne modelDescription.collection, { _id: databaseModule.ObjectId(id) }, (err, result) =>
            cb err, if result then @constructModel(result, modelDescription)
            
            
            
    @destroyAll: (params, db, cb) ->
        modelDescription = @getModelDescription()
        if modelDescription.validateMultiRecordOperationParams(params)
            db.remove modelDescription.collection, params, (err) =>
                cb?(err)
        else
            cb? new AppError "Call to destroyAll() must pass safety checks on params.", "SAFETY_CHECK_FAILED_IN_DESTROYALL"
            
            
            
    @mergeModelDescription: (child, parent) ->
        fields = utils.clone(parent.fields)        
        for k,v of child.fields
            fields[k] = v
        modelDescription = utils.clone(parent)
        for k,v of child
            if k isnt 'fields'
                modelDescription[k] = v
            else
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
                                if @isCustomClass contentType
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

        #Required is true unless explicitly set.
        if not fieldDef.required?
            fieldDef.required = true    
            
        fieldDef
        
    
    
    @getModels: (path = './') =>
        if not @__models
            @__models = require path
        @__models
        
        
        
    getModels: (path = './') =>
        @constructor.getModels path
        
        
    
    save: (context, db, cb) =>
        modelDescription = @constructor.getModelDescription()
        
        for fieldName, def of modelDescription.fields
            if def.autoGenerated
                switch def.event
                    when 'created'
                        if not @_id?
                            @[fieldName] = Date.now()    
                    when 'updated'
                        @[fieldName] = Date.now()                            
        
        @validate (err, errors) =>
            if not errors.length
                fnSave = =>
                    @_updateTimestamp = Date.now()                
                    @_shard = if modelDescription.generateShard? then modelDescription.generateShard(@) else "1"
                    
                    if not @_id?
                        if modelDescription.logging?.isLogged
                            event = {}
                            event.type = modelDescription.logging.onInsert
                            event.data = this
                            db.insert 'events', event, =>
                        
                        db.insert modelDescription.collection, @, (err, r) =>
                            cb? err, r
                    else
                        db.update modelDescription.collection, { _id: @_id }, @, (err, r) =>
                            cb? err, @
            
                if @_id and modelDescription.concurrency is 'optimistic'
                    @constructor.getById @_id, context, db, (err, newPost) =>
                        if newPost._updateTimestamp is @_updateTimestamp
                            fnSave()
                        else
                            cb? new AppError "Update timestamp mismatch. Was #{newPost._updateTimestamp} in saved, #{@_updateTimestamp} in new.", 'OPTIMISTIC_CONCURRENCY_FAIL'
                else
                    fnSave()        
            else
                utils.log "Validation failed for object with id #{@_id} in collection #{modelDescription.collection}."
                for error in errors
                    utils.log error
                utils.log "Error generated at #{Date().toString('yyyy-MM-dd')}."
                cb? new AppError "Model failed validation."


    
    validate: (cb) =>
        _cb = (err, errors) =>
            if cb then cb(err, errors) else errors
            
        modelDescription = @constructor.getModelDescription()
        if not modelDescription.useCustomValidationOnly
            @validateFields modelDescription.fields, (err, errors) =>
                if modelDescription.validate
                    modelDescription.validate.call @, modelDescription.fields, (err, _errors) =>
                        _cb err, errors.concat _errors
                else
                    _cb err, errors
        else
            if modelDescription.validate?
                modelDescription.validate.call @, modelDescription.fields, (err, errors) =>
                    _cb err, errors
            else
                _cb null, []
                        
        

    validateFields: (fields, cb) =>
        errors = []

        for fieldName, def of fields
            BaseModel.addError errors, fieldName, @validateField(@[fieldName], fieldName, def)
            
        if cb
            cb null, errors
        else
            errors
            

    validateField: (value, fieldName, def) =>
        errors = []

        if not def.useCustomValidationOnly                
            fieldDef = BaseModel.getFullFieldDefinition(def)
            
            if fieldDef.required and not value?
                errors.push "#{JSON.stringify fieldName} is #{JSON.stringify value}"
                errors.push "#{fieldName} is required."
            
            #Check types.            
            if value
                if fieldDef.type is 'array'
                    for item in value
                        BaseModel.addError errors, fieldName, @validateField(item, "[#{fieldName} item]", fieldDef.contents)
                else
                    #If it is a custom class
                    if (BaseModel.isCustomClass(fieldDef.type) and not (value instanceof fieldDef.type)) or (not BaseModel.isCustomClass(fieldDef.type) and typeof(value) isnt fieldDef.type)
                        errors.push "#{fieldName} is #{JSON.stringify value}"
                        errors.push "#{fieldName} should be a #{fieldDef.type}."

        if def.validate
            BaseModel.addError(errors, fieldName, def.validate.call @)
        
        errors            
        

    
    destroy: (context, db, cb) =>
        modelDescription = @constructor.getModelDescription()
        db.remove modelDescription.collection, { _id: @_id }, (err) =>
            cb? err, @


    
    @addError: (list, fieldName, error) ->
        if error is true
            return list
        if error is false
            list.push "#{fieldName} is invalid."
            return list
        if error instanceof Array
            if error.length > 0
                for item in error
                    if item instanceof Array
                        BaseModel.addError list, fieldName, item
                    else
                        list.push error
            return list
        if error
            list.push error
            return list

exports.BaseModel = BaseModel

