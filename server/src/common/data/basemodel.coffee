databaseModule = require('./database').Database
Validator = require('./validator').Validator
utils = require('../utils')

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @getTypeDefinition: (model = @) ->
        if typeof model.describeType is "function" then model.describeType() else model.describeType
        
    
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        
        
    
    
    @mergeTypeDefinition: (child, parent) ->
        result = {}
        utils.extend result, child
        utils.extend result, parent, (n) -> n isnt 'fields'
        result.fields ?= {}
        if parent.fields
            utils.extend result.fields, parent.fields 
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
