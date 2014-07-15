class Mapper

    constructor: (@typeUtils) ->
    

    getMappableFields: (typeDef, acc = [], prefix = []) =>*
        for field, def of typeDef.schema.properties
            if not (typeDef.inheritedProperties?.indexOf(field) >= 0)
                if @typeUtils.isPrimitiveType def.type
                    if def.type is 'array' and @typeUtils.isCustomType def.items.type
                            prefix.push field
                            yield* @getMappableFields def.items.typeDefinition, acc, prefix
                            prefix.pop field
                    else
                        acc.push prefix.concat(field).join '_'
                else
                    if @typeUtils.isCustomType def.type
                        prefix.push field
                        yield* @getMappableFields def.typeDefinition, acc, prefix
                        prefix.pop field 
        acc
        
        
module.exports = Mapper


