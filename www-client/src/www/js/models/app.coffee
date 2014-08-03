
AppBase = require('./app-base').AppBase

class App extends AppBase

    @typeDefinition: ->
        typeDef = AppBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* App.getTypesService().getTypeDefinition(obj.type)
            if def.ctor isnt App
                throw new Error "App type definitions must have ctor set to App"
            def
        typeDef


    getTypeDefinition: =>*
        typesService = App.getTypesService()
        yield* typesService.getTypeDefinition(@type)



exports.App = App
