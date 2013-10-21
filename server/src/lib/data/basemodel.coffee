databaseModule = require('./database').Database
utils = require('../utils')
Validator = require('./validator').Validator
typeUtils = new (require('./typeutils').TypeUtils)

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)



    @getTypeDefinition: (inherited = true) ->
        if not @typeDefinition 
            @typeDefinition = if typeof @describeType is "function" then @describeType() else @describeType                

            for field, def of @typeDefinition.fields
                @typeDefinition.fields[field] = @getTypeUtils().getFieldDefinition(def)
        
        if @typeDefinition.inherits
            @fullTypeDefinition = @mergeTypeDefinition @typeDefinition, @typeDefinition.inherits.getTypeDefinition()

        if inherited and @typeDefinition.inherits
            @fullTypeDefinition
        else
            @typeDefinition
        
        
    
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result        
        
    
    
    @mergeTypeDefinition: (child, parent) ->
        if not parent
            return child
        else
            result = {}
            utils.extend result, child, (n) -> n isnt 'fields'
            utils.extend result, parent, (n) -> n isnt 'fields'
            result.fields = {}
            if child.fields
                utils.extend result.fields, child.fields 
            if parent.fields
                utils.extend result.fields, parent.fields 
            result



    @getTypeUtils: ->
        typeUtils


    
    validate: (modelDescription = @getTypeDefinition()) ->
        validator = new Validator @constructor.getTypeUtils()
        validator.validate @, modelDescription
            


    validateField: (value, fieldName, modelDescription = @getTypeDefinition()) ->
        validator = new Validator @constructor.getTypeUtils()
        validator.validateField @, value, fieldName, modelDescription
        


    getTypeDefinition: (inherited) =>
        @constructor.getTypeDefinition inherited
            

    
    toJSON: ->
        result = {}
        for k,v of @
            if not /^__/.test(k) 
                result[k] = v
        result



exports.BaseModel = BaseModel
