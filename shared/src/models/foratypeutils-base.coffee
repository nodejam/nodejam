odm = require('fora-models')


class ForaTypeUtilsBase extends odm.TypeUtils

    init: (@builtinTypes) =>*
        yield @buildTypeCache()


    getCacheItems: =>*
        definitions = {}
        
        for defs in [yield @getModelTypeDefinitions(), yield @getTrustedUserTypes()]
            for name, def of defs
                definitions[name] ?= def    
        
        return definitions
        
    
    
    getModelTypeDefinitions: =>*
        #Get type definitions from models
        models = []

        fnAdd = (module) ->
            for name, model of module
                models.push model
                if model.childModels                    
                    fnAdd model.childModels

        for module in @builtinTypes
            fnAdd module
        
        definitions = {}
        
        for model in models            
            def = if typeof model.typeDefinition is "function" then model.typeDefinition() else model.typeDefinition
            def = @completeTypeDefinition(def, model)
            definitions[def.name] ?= def
        
        definitions
        
    
    
    getTrustedUserTypes: =>*
        throw new Error "getTrustedUserTypes() method must be overridden in derived class."



    resolveDynamicTypeDefinition: (name) =>*
        #TODO: make sure we dont allow special characters in name, like '..'
        console.log "Missing " + JSON.stringify name
        
        
exports.ForaTypeUtilsBase = ForaTypeUtilsBase
