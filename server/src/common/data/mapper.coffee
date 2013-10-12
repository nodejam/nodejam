utils = require '../utils'
typeutils = require './typeutils'

class Mapper

    map: (target, sources) =>
        typeDef = target.getTypeDefinition()
        
        source = {}
        for src in sources
            utils.extend source, src
        
        for field, def of typeDef.fields 
            @getValue target, field, def, [], source

        target


    
    getValue: (obj, name, def, prefix, source) =>
        def = typeutils.getFullTypeDefinition def
        fullName = prefix.concat(name).join '_'
        if not typeutils.isUserDefinedType(def.type)
            val = source[fullName]
            
            if val
                if def.type isnt 'array'
                    obj[name] = @parsePrimitive val, def.type
                else
                    if def.map?.sourceFormat is 'csv'
                        contentType = typeutils.getFullTypeDefinition def.contentType
                        obj[name] = (@parsePrimitive(vs, contentType) for v in val.split(','))
                    else
                        throw new Error "Mapper cannot parse this array: Unknown sourceFormat"
            else
                if name isnt '_id' and def.map isnt false and def.default
                    obj[name] = if typeof def.map.default is "function" then def.map.default(obj, source) else def.map.default
        else
            prefix.push name    
            obj[name] = if def.type is 'object' or def.type is '' then {} else new def.type()           
            for name, def of def.type.getTypeDefinition().fields
                @getValue obj[name], name, def, prefix, source
            prefix.pop()
     

     
    parsePrimitive: (val, type) =>
        switch type
            when 'number'
                (if def.integer then parseInt else parseFloat) val
            when 'string'
                val
            when 'boolean'
                val is "true"
            else
                throw new Error "Mapper cannot parse this array: Unknown sourceFormat"
        
        
exports.Mapper = Mapper
