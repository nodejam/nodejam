RecordExtension = require('./recordextension')
AppExtension = require('./appextension')

class Loader

    @builtinExtensionCache = {}


    constructor: (@typeUtils, @settings) ->


    init: =>*
        return
        yield false


    load: (typeDefinition) =>*
        if typeDefinition.extensionType is 'builtin'
            switch typeDefinition.type
                when 'app'
                    return new AppExtension(typeDefinition, this)
                when 'post'
                    return new RecordExtension(typeDefinition, this)
        else
            throw new Error "Untrusted extensions are not implemented yet"

        yield false

exports.Loader = Loader
