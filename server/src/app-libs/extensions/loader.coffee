co = require 'co'
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()

builtin = {
    forum: require './builtin/forum',
    post:  require './builtin/post'
}

untrusted = {
    forum: require './untrusted/forum',
    post:  require './untrusted/post'
}

class Loader

    @builtinExtensionCache = {}


    #preload all builtin extensions
    init: =>*
        defs = typeUtils.getTypeDefinitions()
        for def in defs
            console.log "loading #{def.name}"
            if def.extensionType is 'builtin'
                ext = new builtin[typeDefinition.type] typeDefinition
                yield ext.init()
                Loader.builtinExtensionCache[typeDefinition.name] = ext
        return
    
    
            
    load: (typeDefinition) ->*
        if typeDefinition.extensionType is 'builtin'
            return Loader.builtinExtensionCache[typeDefinition.name]        
        else
            ext = new untrusted[typeDefinition.type] typeDefinition
            yield ext.init()
            return ext
            

module.exports = Loader
