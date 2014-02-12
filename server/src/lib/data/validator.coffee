class Validator

    constructor: (@typeUtils) ->
        

    validate: (obj, typeDefinition) ->*
        errors = []
        
        for fieldName, def of typeDefinition.schema.properties                
            @addError errors, fieldName, yield @validateField(obj, obj[fieldName], fieldName, def)

        if typeDefinition.schema.required?.length
            for field in typeDefinition.schema.required
                if typeof obj[field] is 'undefined'
                    errors.push "#{field} is required"

        if typeDefinition.validate
            customValidationResults = yield typeDefinition.validate.call obj
            return if customValidationResults?.length then errors.concat customValidationResults else errors
        else
            return errors
    
    
    
    validateField: (obj, value, fieldName, fieldDef) ->*
        errors = []

        #Check types.       
        if value?
            
            if fieldDef.type is 'array'
                if fieldDef.minItems and value.length < fieldDef.minItems
                    errors.push "#{fieldName}: must have at least #{fieldDef.minItems} elements"
                if fieldDef.maxItems and value.length > fieldDef.maxItems
                    errors.push "#{fieldName}: can have at most #{fieldDef.minItems} elements"
                
                for item in value
                    if @typeUtils.isCustomType(fieldDef.items.type)
                        if item.validate
                            errors = errors.concat yield item.validate()
                        else if fieldDef.items.typeDefinition
                            errors = errors.concat yield @validate item, fieldDef.items.typeDefinition
                    else
                        errors = errors.concat yield @validateField obj, item, "[#{fieldName}]", fieldDef.items           
            
            else
                typeCheck = (fn) ->
                    if not fn()
                        errors.push "#{fieldName}: expected #{fieldDef.type} but is #{JSON.stringify value}"
                    
                switch fieldDef.type
                    when 'integer'
                        typeCheck -> value % 1 is 0
                    when 'number'
                        typeCheck -> typeof value is 'number'
                    when 'string'
                        typeCheck -> typeof value is 'string'
                    when 'boolean'
                        typeCheck -> typeof value is 'boolean'
                    else
                        if @typeUtils.isCustomType(fieldDef.type)
                            if value.validate
                                errors = errors.concat yield value.validate()
                            else if fieldDef.typeDefinition
                                errors = errors.concat yield @validate value, fieldDef.typeDefinition
        
        errors            



    addError: (list, fieldName, error) ->
        if error is true
            return list
        if error is false
            list.push "#{fieldName} is invalid."
            return list
        if error instanceof Array
            if error.length > 0
                for item in error
                    @addError list, fieldName, item
            return list
        if error
            list.push error
            return list


exports.Validator = Validator
        
