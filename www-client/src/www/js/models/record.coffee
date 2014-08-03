
RecordBase = require('./record-base').RecordBase
TextContent = require('./fields').TextContent

class Record extends RecordBase

    @typeDefinition: ->
        typeDef = RecordBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* Record.getTypeService().getTypeDefinition(obj.type)
            if def.ctor isnt Record
                throw new Error "Record type definitions must have ctor set to Record"
            def
        typeDef


    constructor: (params) ->
        super
        if (!(@content instanceof TextContent))
            @content = new TextContent(@content)


    getTypeDefinition: =>*
        typeService = Record.getTypeService()
        yield* typeService.getTypeDefinition(@type)


exports.Record = Record
