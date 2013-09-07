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
