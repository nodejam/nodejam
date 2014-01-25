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


    
    init: ->*
        if not initted
            @rawBody = yield body @ctx
            initted = true            
    
    
    
    body: (name, def) =>*
        def ?= { type: 'string' }
        if typeof def is 'string'
            def = { type: def }
        @parsePrimitive @rawBody[name], def, name

    
    
    files: =>*
        (yield* multipart @ctx).files
            


    map: (target, whitelist, options = { overwrite: true }, prefix = []) =>*
        result = { changed: false }
        @init()
        typeDef = yield target.getTypeDefinition()     
        for field, def of typeDef.schema.properties
            populateResult = yield @populateObject target, field, def, whitelist, options, prefix
            result.changed = populateResult.changed
        yield result
   
        
    
    populateObject: (obj, name, def, whitelist, options, prefix) =>*
        result = { changed: false }

        if not obj[name] or options.overwrite
            fullName = prefix.concat(name).join('_').toLowerCase()
            if @typeUtils.isPrimitiveType(def.type) and def.type isnt 'array'
                if whitelist.indexOf(fullName) > -1
                    val = yield @body fullName, 'string'
                    if val
                        obj[name] = @parsePrimitive val, def, fullName
                        result.changed = true
            else
                prefix.push name

                if def.typeDefinition                    
                    newObj = new def.typeDefinition.ctor()
                    mapResult = @map(newObj, whitelist, options, prefix)
                    if mapResult.changed
                        obj[name] = newObj
                        result.changed = true
                    
                prefix.pop()

        yield result



    parsePrimitive: (val, def, fieldName) =>
        if val
            switch def.type
                when 'integer'
                    parseInt val
                when 'number'
                    parseFloat val
                when 'string'
                    if def.allowHtml
                        sanitizer.sanitize(sanitizer.unescapeEntities val)
                    else
                        sanitizer.escape(val)
                when 'boolean'
                    val is "true"
                else      
                    throw new Error "#{def.type} #{fieldName} is a non-primitive. Cannot parse."

exports.RequestParser = RequestParser
