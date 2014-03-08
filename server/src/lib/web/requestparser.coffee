###
    A safe wrapper around the request to hide access to query, params and body.
    This allows us to sanitize those fields when requested.    
###

utils = require '../utils'
validator = require 'validator'
sanitizer = require 'sanitizer'
co = require 'co'
body = require 'co-body'
multipart = require 'co-multipart'

class RequestParser

    constructor: (@ctx, @typeUtils) ->


    
    body: (name, def = { type: 'string' }) =>*
        if not @initted
            @rawBody = yield body @ctx
            @initted = true            

        if typeof def is 'string'
            def = { type: def }
        value = @rawBody[name]
        if value
            @parseSimpleType value, name, def

    
    
    files: =>*
        (yield* multipart @ctx).files



    map: (target, whitelist, options = { overwrite: true }, parents = []) =>*
        whitelist = (f.split('_') for f in whitelist)
        yield @map_impl target, whitelist, options, parents
        


    map_impl: (target, whitelist, options, parents) =>*
        typeDef = yield target.getTypeDefinition()     
        for fieldName, def of typeDef.schema.properties
            fieldWhiteList = (a for a in whitelist when a[0] is fieldName)        
            if yield @setField target, fieldName, def, typeDef, fieldWhiteList, options, parents
                changed = true

        return changed
   
        

    setField: (obj, fieldName, def, typeDef, whitelist, options, parents) =>*
        if @typeUtils.isPrimitiveType(def.type)
            if def.type isnt 'array'
                if whitelist[0]?[0] is fieldName
                    yield @setSimpleType(obj, fieldName, def, typeDef, whitelist, options, parents)
            else
                yield @setArray(obj, fieldName, def, typeDef, whitelist, options, parents)
        else
            yield @setCustomType(obj, fieldName, def, typeDef, whitelist, options, parents)
                        
                        

    #eg: name: "jeswin", age: 33    
    setSimpleType: (obj, fieldName, def, typeDef, whitelist, options, parents) =>*
        formField = parents.concat(fieldName).join('_')
        val = yield @body formField
        if val
            result = @parseSimpleType val, fieldName, def, typeDef
            if not (obj instanceof Array)
                if options.overwrite
                    obj[fieldName] = result
                else
                    obj[fieldName] ?= result
                changed = true
            else
                obj.push result
                changed = true
            
        return changed    
            


    #Two possibilities
    #1. Array of primitives (eg: customerids_1: 13, customerids_2: 44, or as CSV like customerids: "1,54,66,224")
    #2. Array of objects (eg: customers_1_name: "jeswin", customers_1_age: "33")
    setArray: (obj, fieldName, def, typeDef, whitelist, options, parents) =>*   
        if typeDef?.mapping?[fieldName]
            if def.items.type isnt 'array'
                if whitelist.indexOf(fieldName) isnt -1
                    formField = parents.concat(fieldName).join('_')
                    val = yield @body formField
                    items = val.split ','
                    for i in items
                        obj[fieldName].push @parseSimpleType val, "#{fieldName}[]", def.items, def
                        changed = true
            else
                throw new Error "Cannot map array of arrays"
        else
            parents.push fieldName

            counter = 1
            newArray = obj[fieldName] ? []
            while true
                if yield @setField(newArray, counter, def.items, def, whitelist, options, parents)
                    counter++
                    obj[fieldName] ?= newArray
                    changed = true
                else
                    break                        

            parents.pop()
            
        return changed

    
    
    setCustomType: (obj, fieldName, def, typeDef, whitelist, options, parents) =>*
        whitelist = (a[1..] for a in whitelist)
        parents.push fieldName

        if def.typeDefinition?.ctor
            newObj = new def.typeDefinition.ctor()
            changed = yield @map_impl(newObj, whitelist, options, parents)
            if changed
                if not (obj instanceof Array)
                    obj[fieldName] = newObj                    
                else
                    obj.push newObj

        parents.pop() 
                   
        return changed    



    parseSimpleType: (val, fieldName, def, typeDef) =>
        if val
            switch def.type
                when 'integer'
                    parseInt val
                when 'number'
                    parseFloat val
                when 'string'
                    if typeDef?.htmlFields?.indexOf(fieldName) isnt -1
                        sanitizer.sanitize(sanitizer.unescapeEntities val)
                    else
                        sanitizer.escape(val)
                when 'boolean'
                    val is "true"
                else      
                    throw new Error "#{def.type} #{fieldName} is not a primitive type or is an array. Cannot parse."

exports.RequestParser = RequestParser
