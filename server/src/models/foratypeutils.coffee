TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    resolveType: (name) =>
        if not ForaTypeUtils.Cache
            ForaTypeUtils.Cache = {}
            
        if not ForaTypeUtils.Cache[name]
            @loadType require('./'), ForaTypeUtils.Cache
            @loadType require('./fields'), ForaTypeUtils.Cache

        ForaTypeUtils.Cache[name]
        
        
        
    loadType: (ns, cache) =>
        for k, v of ns
            typeDef = if typeof v.typeDefinition is "function" then v.typeDefinition() else v.typeDefinition
            cache[typeDef.name] = typeDef.type
            
            if typeDef.type.childModels
                @loadType typeDef.type.childModels, cache           
                        
exports.ForaTypeUtils = ForaTypeUtils
