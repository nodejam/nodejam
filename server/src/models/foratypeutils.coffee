TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    getCacheItems: =>
        #Get type definitions from models
        models = []

        fnAdd = (module) ->
            for name, model of module
                models.push model
                if model.childModels                    
                    fnAdd model.childModels

        for moduleName in ['./', './fields']
            fnAdd require moduleName

        fnBuildDef = (td) ->
            
            
        definitions = {}
        
        for model in models            
            def = if typeof model.typeDefinition is "function" then model.typeDefinition() else model.typeDefinition
            def = @completeTypeDefinition(def, model)
            definitions[def.name] ?= def
        
        #Get type definitions from extensions
        Post = require('./post').Post
        postTypeDef = if typeof Post.typeDefinition is "function" then Post.typeDefinition() else Post.typeDefinition
        
        for module in require('../extensions/posts/models')
            definitions[module.typeDefinition.name] ?= module.typeDefinition
            module.typeDefinition.collection = postTypeDef.collection
            
            for k, v of postTypeDef.schema.properties
                module.typeDefinition.schema.properties[k] = v
            
            for req in postTypeDef.schema.required
                if module.typeDefinition.schema.required.indexOf(req) is -1
                    module.typeDefinition.schema.required.push req        
        
        return definitions
        
        
        
    resolveDynamicTypeDefinition: (name) =>*
        for x, y of TypeUtils.typeCache
            console.log "Found " + x
        console.log "Missing " + JSON.stringify name
        
        
                        
exports.ForaTypeUtils = ForaTypeUtils
