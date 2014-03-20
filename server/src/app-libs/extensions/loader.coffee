class Loader

    load: (typeDefinition) ->
        switch typeDefinition.extensionType
            when 'builtin'
                new BuiltInProxy typeDefinition
            else
                new UntrustedProxy typeDefinition
    
modile.exports = Loader
