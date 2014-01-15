TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    resolveUserDefinedType: (name) =>*
        if not ForaTypeUtils.Cache
            ForaTypeUtils.Cache = {}
            
        if not ForaTypeUtils.Cache[name]
            @loadTypes require('./'), ForaTypeUtils.Cache
            @loadTypes require('./fields'), ForaTypeUtils.Cache

        ForaTypeUtils.Cache[name] ? new DynamicType()
        
        
    loadTypes: (ns, cache) =>
        for k, v of ns
            typeDef = if typeof v.typeDefinition is "function" then v.typeDefinition() else v.typeDefinition
            cache[typeDef.name] = typeDef.type
            
            if typeDef.type.childModels
                @loadTypes typeDef.type.childModels, cache           
                        
exports.ForaTypeUtils = ForaTypeUtils
