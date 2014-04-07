co = require 'co'
utils = require('../../lib/utils')
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()

builtin = {
    forum: require('./builtin/forum'),
    post:  require('./builtin/post')
}

untrusted = {
    forum: require('./untrusted/forum'),
    post:  require('./untrusted/post')
}

class Loader

    @builtinExtensionCache = {}


    #preload all builtin extensions
    init: =>*
        defs = typeUtils.getTypeDefinitions()
        for name, def of defs
            if def.extensionType is 'builtin'
                ctor = builtin[def.type]
                ext = new ctor def, this
                console.log "loading builtin extension " + def.name
                yield ext.init()
                Loader.builtinExtensionCache[def.name] = ext
        utils.log 'Extension loading complete'
        return
    
    
            
    load: (typeDefinition) =>*
        if typeDefinition.extensionType is 'builtin'
            return Loader.builtinExtensionCache[typeDefinition.name]        
        else
            ext = new untrusted[typeDefinition.type] typeDefinition
            yield ext.init()
            return ext
            

module.exports = Loader
