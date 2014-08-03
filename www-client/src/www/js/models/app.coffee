
AppBase = require('./app-base').AppBase

class App extends AppBase

    @typeDefinition: ->
        typeDef = AppBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* App.getTypeService().getTypeDefinition(obj.type)
            if def.ctor isnt App
                throw new Error "App type definitions must have ctor set to App"
            def
        typeDef


    getTypeDefinition: =>*
        typeService = App.getTypeService()
        yield* typeService.getTypeDefinition(@type)



exports.App = App
