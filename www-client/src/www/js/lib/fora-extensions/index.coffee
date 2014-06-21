class PostExtension

    constructor: (@typeDefinition, @loader) ->
    

    getTemplateModule: (name) =>*

        requireThunk = (name) =>
            url = "/shared/extensions/#{@typeDefinition.name}/templates/#{name}.js"
            return (cb) ->
                require [url], ->
                    cb null, arguments[0]
    
        yield requireThunk(name)

    

class ForumExtension



class ExtensionLoader

    constructor: ->
    

    load: (typeDefinition) =>*
        if typeDefinition.extensionType is 'builtin'
            switch typeDefinition.type
                when 'forum'
                    return new ForumExtension(typeDefinition, this)
                when 'post'
                    return new PostExtension(typeDefinition, this)                
        else
            throw new Error "Untrusted extensions are not implemented yet"
        
    


class Loader

    @builtinExtensionCache = {}


    constructor: (@typeUtils, @settings) ->


    init: =>*
    
    
            
    load: (typeDefinition) =>*
        debugger

exports.Loader = Loader
