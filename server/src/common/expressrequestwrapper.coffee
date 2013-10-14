###
    A safe wrapper around the request to hide access to query, params and body.
    This allows us to sanitize those fields when requested.    
###

utils = require './utils'
typeutils = require './data/typeutils'
validator = require 'validator'

class ExpressRequestWrapper

    constructor: (@raw) ->
        @headers = @raw.headers

    
    
    getParameter: (src, name, def = "string") =>
        if typeof def is 'string' 
            def = typeutils.getFieldDefinition def
        val = @raw[src][name]
        @parsePrimitive val, def, name
        

    
    params: (name, type) =>
        @getParameter 'params', name, type
        

    
    query: (name, type) =>
        @getParameter 'query', name, type



    body: (name, type) =>
        @getParameter 'body', name, type
    

    
    cookies: (name, type) =>
        @getParameter 'cookies', name, type
        
    
    
    files: =>
        @raw.files


    
    map: (target, fields) =>
        typeDef = target.getTypeDefinition()        
        for field, def of typeDef.fields
            if fields.indexOf(field) > -1
                @populateObject target, field, def, []


    
    populateObject: (obj, name, def, prefix) =>
        if name isnt '_id'
            def = typeutils.getFieldDefinition def
            fullName = prefix.concat(name).join '_'
            if not typeutils.isUserDefinedType(def.type)
                val = @body fullName, 'string'
                if val
                    obj[name] = @parsePrimitive val, def, fullName                
                else
                    if def.map isnt false and def.default
                        obj[name] = if typeof def.map.default is "function" then def.map.default(obj) else def.map.default
            else
                prefix.push name    
                obj[name] = if def.type is 'object' or def.type is '' then {} else new def.type()           
                for name, def of def.type.getTypeDefinition().fields
                    @populateObject obj[name], name, def, prefix
                prefix.pop()        



    parsePrimitive: (val, def, fieldName) =>
        switch def.type
            when 'number'
                (if def.integer then parseInt else parseFloat) val
            when 'string'
                val
            when 'boolean'
                val is "true"
            when 'array'
                if def.map?.sourceFormat is 'csv'
                    contentType = typeutils.getFullTypeDefinition def.contentType
                    (@parsePrimitive(vs, contentType, fieldName) for v in val.split(','))                    
                else
                    throw new Error "Cannot parse this array. Unknown sourceFormat."
            else      
                throw new Error "#{def.type} #{fieldName} is a non-primitive. Cannot parse."
                
exports.ExpressRequestWrapper = ExpressRequestWrapper
