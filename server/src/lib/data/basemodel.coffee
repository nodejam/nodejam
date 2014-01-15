databaseModule = require('./database').Database
utils = require('../utils')
Validator = require('./validator').Validator
typeUtils = new (require('./typeutils').TypeUtils)

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @getTypeDefinition: (inherited = true) ->*        
        yield (@getTypeUtils().getTypeDefinition) @, inherited
        
        
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        



    @getTypeUtils: ->
        typeUtils


    
    validate: (modelTypeDefinition) ->*
        modelTypeDefinition ?= yield @getTypeDefinition()
        validator = new Validator @constructor.getTypeUtils()
        yield validator.validate @, modelTypeDefinition
            


    validateField: (value, fieldName, modelTypeDefinition) ->*
        modelTypeDefinition ?= yield @getTypeDefinition()
        validator = new Validator @constructor.getTypeUtils()
        yield validator.validateField @, value, fieldName, modelTypeDefinition
        


    getTypeDefinition: (inherited) =>*
        yield @constructor.getTypeDefinition inherited
            

    
    toJSON: ->
        result = {}
        for k,v of @
            if not /^__/.test(k) 
                result[k] = v
        result



exports.BaseModel = BaseModel
