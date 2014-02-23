utils = require '../utils'
Validator = require './validator'

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @getTypeDefinition: ->*
        if not @__typeDefinition
            typeDef = if typeof @typeDefinition is "function" then @typeDefinition() else @typeDefinition
            @__typeDefinition = yield @getTypeUtils().getTypeDefinition(typeDef.name)
            if not @__typeDefinition
                throw new Error "CANNOT_RESOLVE_TYPE_DEFINITION"
        @__typeDefinition
            
            
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        



    validate: (typeDefinition) ->*
        typeDefinition ?= yield @getTypeDefinition()
        validator = new Validator @constructor.getTypeUtils()
        yield validator.validate @, typeDefinition
            


    validateField: (value, fieldName, typeDefinition) ->*
        typeDefinition ?= yield @getTypeDefinition()
        validator = new Validator @constructor.getTypeUtils()
        yield validator.validateField @, value, fieldName, typeDefinition
        

    
    getTypeDefinition: =>*
        yield @constructor.getTypeDefinition()



    toJSON: ->
        result = {}
        for k,v of @
            if not /^__/.test(k) 
                result[k] = v
        result



module.exports = BaseModel
