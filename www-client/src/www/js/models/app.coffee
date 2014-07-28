
AppBase = require('./app-base').AppBase

class App extends AppBase

    @typeDefinition: ->
        typeDef = AppBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* App.getTypeUtils().getTypeDefinition(obj.type)
            if def.ctor isnt App
                throw new Error "App type definitions must have ctor set to App"
            def
        typeDef


    getTypeDefinition: =>*
        typeUtils = App.getTypeUtils()
        yield* typeUtils.getTypeDefinition(@type)



exports.App = App
