randomizer = require '../lib/randomizer'
models = require './'
conf = require '../conf'

ForaTypeService = require('./foratypeutils')
typeService = new ForaTypeService()

Loader = require('fora-extensions').Loader
extensionLoader = new Loader(typeService, { directory: require("path").resolve(__dirname, '../extensions') })

RecordBase = require('./record-base').RecordBase
models = require('./')

class Record extends RecordBase

    @typeDefinition: ->
        typeDef = RecordBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* Record.getTypeService().getTypeDefinition(obj.type)
            if def.ctor isnt Record
                throw new Error "Record type definitions must have ctor set to Record"
            def
        typeDef


    @search: (criteria, settings, context, db) =>
        limit = @getLimit settings.limit, 100, 1000

        params = {}
        for k, v of criteria
            params[k] = v

        Record.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, db



    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result



    constructor: (params) ->
        super
        @meta ?= []
        @tags ?= []



    addMetaList: (metaList) =>*
        @meta = @meta.concat (m for m in metaList when @meta.indexOf(m) is -1)
        yield* @save()



    removeMetaList: (metaList) =>*
        @meta = (m for m in @meta when metaList.indexOf(m) is -1)
        yield* @save()



    save: (context, db) =>*
        { context, db } = @getContext context, db

        extensions = yield* extensionLoader.load yield* @getTypeDefinition()
        model = yield* extensions.getModel()
        yield* model.save.call @

        #if stub is a reserved name, change it
        if @stub
            if conf.reservedNames.indexOf(@stub) > -1
                throw new Error "Stub cannot be #{@stub}, it is reserved"

                regex = '[a-z][a-z0-9|-]*'
                if not regex.text @stub
                    throw new Error "Stub is invalid"
        else
            @stub ?= randomizer.uniqueId(16)

        result = yield* super(context, db)

        if @state is 'published'
            app = yield* models.App.getById @appId, context, db
            yield* app.refreshCache()

        result



    getCreator: =>*
        { context, db } = @getContext context, db
        yield* models.User.getById @createdById, {}, db



    getView: (name) =>*
        extensions = yield* extensionLoader.load yield* @getTypeDefinition()
        model = yield* extensions.getModel()
        yield* model.view.call @, name

exports.Record = Record
