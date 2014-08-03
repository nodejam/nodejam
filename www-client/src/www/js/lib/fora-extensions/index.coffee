RecordExtension = require('./recordextension')
AppExtension = require('./appextension')

class Loader

    @builtinExtensionCache = {}


    constructor: (@typeService, @settings) ->


    init: =>*
        return
        yield false


    load: (typeDefinition) =>*
        if typeDefinition.extensionType is 'builtin'
            switch typeDefinition.type
                when 'app'
                    return new AppExtension(typeDefinition, this)
                when 'record'
                    return new RecordExtension(typeDefinition, this)
                else
                    throw new Error "Extension must either be an app or record"
        else
            throw new Error "Untrusted extensions are not implemented yet"

        yield false

exports.Loader = Loader
