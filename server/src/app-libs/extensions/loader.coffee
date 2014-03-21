BuiltInExtension = require './builtin'
UntrustedExtension = require './untrusted'

class Loader

    load: (typeDefinition) ->
        switch typeDefinition.extensionType
            when 'builtin'
                new BuiltInExtension typeDefinition
            else
                new UntrustedExtension typeDefinition
    
module.exports = Loader
