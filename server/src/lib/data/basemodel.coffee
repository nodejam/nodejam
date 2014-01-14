databaseModule = require('./database').Database
utils = require('../utils')
Validator = require('./validator').Validator
typeUtils = new (require('./typeutils').TypeUtils)

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @getTypeDefinition: (inherited = true) ->    
        @getTypeUtils().getTypeDefinition @, inherited
        
        
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        



    @getTypeUtils: ->
        typeUtils


    
    validate: (modelTypeDefinition = @getTypeDefinition()) ->
        validator = new Validator @constructor.getTypeUtils()
        validator.validate @, modelTypeDefinition
            


    validateField: (value, fieldName, modelTypeDefinition = @getTypeDefinition()) ->
        validator = new Validator @constructor.getTypeUtils()
        validator.validateField @, value, fieldName, modelTypeDefinition
        


    getTypeDefinition: (inherited) =>
        @constructor.getTypeDefinition inherited
            

    
    toJSON: ->
        result = {}
        for k,v of @
            if not /^__/.test(k) 
                result[k] = v
        result



exports.BaseModel = BaseModel
