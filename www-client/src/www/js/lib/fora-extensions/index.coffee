PostExtension = require('./postextension')
ForumExtension = require('./forumextension')

class Loader

    @builtinExtensionCache = {}


    constructor: (@typeUtils, @settings) ->


    init: =>*
        return
        yield false


    load: (typeDefinition) =>*
        if typeDefinition.extensionType is 'builtin'
            switch typeDefinition.type
                when 'forum'
                    return new ForumExtension(typeDefinition, this)
                when 'post'
                    return new PostExtension(typeDefinition, this)
        else
            throw new Error "Untrusted extensions are not implemented yet"
            
        yield false

exports.Loader = Loader
