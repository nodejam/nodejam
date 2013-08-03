databaseModule = require('../common/database').Database
utils = require('../common/utils')
AppError = require('../common/apperror').AppError
defer = require('../common/deferred').defer

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        if @_id
            @_id = databaseModule.ObjectId(@_id)


           
    @get: (params, context, db) ->
        modelDescription = @getModelDescription()
        db.findOne(modelDescription.collection, params)
            .then (result) =>
                if result then @constructModel result, modelDescription



    @getAll: (params, context, db) ->
        modelDescription = @getModelDescription()
        db.find(modelDescription.collection, params)
            .then (cursor) =>
                deferred = defer()
                
                cursor.toArray (err, items) =>
                    if err
                        deferred.reject err
                    else
                        deferred.resolve if items?.length then (@constructModel(item, modelDescription) for item in items) else []

                deferred.promise
                    

    
    @find: (params, fnCursor, context, db) ->
        modelDescription = @getModelDescription()
        db.find(modelDescription.collection, params)
            .then (cursor) =>
                deferred = defer()

                fnCursor cursor
                cursor.toArray (err, items) =>
                    if err
                        deferred.reject err
                    else
                        deferred.resolve if items?.length then (@constructModel(item, modelDescription) for item in items) else []    

                deferred.promise



    @getCursor: (params, context, db) ->
        modelDescription = @getModelDescription()
        db.find modelDescription.collection, params


           
    @getById: (id, context, db) ->
        modelDescription = @getModelDescription()
        db.findOne(modelDescription.collection, { _id: databaseModule.ObjectId(id) })
            .then (result) =>
                if result then @constructModel(result, modelDescription)
            
            
            
    @destroyAll: (params, db) ->
        modelDescription = @getModelDescription()
        if modelDescription.validateMultiRecordOperationParams(params)
            db.remove(modelDescription.collection, params)
        else
            defer().reject new AppError "Call to destroyAll() must pass safety checks on params.", "SAFETY_CHECK_FAILED_IN_DESTROYALL"

            
            
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
        deferred = defer()

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
            fnSave = =>
                @_updateTimestamp = Date.now()                
                @_shard = if modelDescription.generateShard? then modelDescription.generateShard(@) else "1"
                
                if not @_id?
                    if modelDescription.logging?.isLogged
                        event = {}
                        event.type = modelDescription.logging.onInsert
                        event.data = this
                        db.insert('events', event)
                    
                    db.insert(modelDescription.collection, @)
                        .then (item) =>
                            deferred.resolve item
                else
                    db.update(modelDescription.collection, { _id: @_id }, @)
                        .then (item) =>
                            deferred.resolve item
        
            if @_id and modelDescription.concurrency is 'optimistic'
                @constructor.getById(@_id, context, db)
                    .then (_item) =>
                        if _item._updateTimestamp is @_updateTimestamp
                            fnSave()
                        else
                            deferred.reject new AppError "Update timestamp mismatch. Was #{_item._updateTimestamp} in saved, #{@_updateTimestamp} in new.", 'OPTIMISTIC_CONCURRENCY_FAIL'
            else
                fnSave()        
        else
            utils.log "Validation failed for object with id #{@_id} in collection #{modelDescription.collection}."
            for error in errors
                utils.log error
            utils.log "Error generated at #{Date().toString('yyyy-MM-dd')}."
            
            deferred.reject new AppError "Model failed validation."

        deferred.promise


    
    validate: =>
        modelDescription = @constructor.getModelDescription()       
        
        if not modelDescription.useCustomValidationOnly
            errors = @validateFields modelDescription.fields
            if modelDescription.validate
                errors.concat modelDescription.validate.call(@, modelDescription.fields)
            else
                errors
        else
            if modelDescription.validate
                modelDescription.validate.call @, modelDescription.fields
            else
                []
                        
        

    validateFields: (fields) =>
        errors = []

        for fieldName, def of fields
            BaseModel.addError errors, fieldName, @validateField(@[fieldName], fieldName, def)

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
                    if fieldDef.type isnt ''
                        if (BaseModel.isCustomClass(fieldDef.type) and not (value instanceof fieldDef.type)) or (not BaseModel.isCustomClass(fieldDef.type) and typeof(value) isnt fieldDef.type)
                            errors.push "#{fieldName} is #{JSON.stringify value}"
                            errors.push "#{fieldName} should be a #{fieldDef.type}."

        if def.validate            
            BaseModel.addError(errors, fieldName, def.validate.call @)
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
                    if item instanceof Array
                        BaseModel.addError list, fieldName, item
                    else
                        list.push error
            return list

        if error
            list.push error
            return list


exports.BaseModel = BaseModel

