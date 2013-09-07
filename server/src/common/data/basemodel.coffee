databaseModule = require('./database').Database
Validator = require('./validator').Validator
utils = require('../utils')

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)

            
            
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
                
                
    
    @getTypeDefinition: (model = @) ->
        if typeof model.describeType is "function" then model.describeType() else model.describeType
        
    
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        
        
    
    
    validate: (modelDescription = @getTypeDefinition()) ->
        Validator.validate @, modelDescription
            


    getTypeDefinition: =>
        @constructor.getTypeDefinition()
            
    
    
    toJSON: ->
        result = {}
        for k,v of @
            if not /^__/.test(k) 
                result[k] = v
        result



exports.BaseModel = BaseModel
