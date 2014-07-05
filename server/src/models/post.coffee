randomizer = require '../lib/randomizer'
models = require './'
conf = require '../conf'

ForaTypeUtils = require('./foratypeutils')
typeUtils = new ForaTypeUtils()

Loader = require('fora-extensions').Loader
extensionLoader = new Loader(typeUtils, { directory: require("path").resolve(__dirname, '../extensions') })

PostBase = require('./post-base').PostBase
models = require('./')

class Post extends PostBase

    @typeDefinition: ->
        typeDef = PostBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield Post.getTypeUtils().getTypeDefinition(obj.type)
            if def.ctor isnt Post
                throw new Error "Post type definitions must have ctor set to Post"
            def
        typeDef


    @search: (criteria, settings, context, db) =>
        limit = @getLimit settings.limit, 100, 1000

        params = {}
        for k, v of criteria
            params[k] = v

        Post.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, db



    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result



    constructor: (params) ->
        super
        @recommendations ?= []
        @meta ?= []
        @tags ?= []



    addMetaList: (metaList) =>*
        @meta = @meta.concat (m for m in metaList when @meta.indexOf(m) is -1)
        yield @save()



    removeMetaList: (metaList) =>*
        @meta = (m for m in @meta when metaList.indexOf(m) is -1)
        yield @save()



    save: (context, db) =>*
        { context, db } = @getContext context, db

        extensions = yield extensionLoader.load yield @getTypeDefinition()
        model = yield extensions.getModel()
        yield model.save.call @

        #if stub is a reserved name, change it
        if @stub
            if conf.reservedNames.indexOf(@stub) > -1
                throw new Error "Stub cannot be #{@stub}, it is reserved"

                regex = '[a-z][a-z0-9|-]*'
                if not regex.text @stub
                    throw new Error "Stub is invalid"
        else
            @stub ?= randomizer.uniqueId(16)

        result = yield super(context, db)

        if @state is 'published'
            forum = yield models.Forum.getById @forumId, context, db
            yield forum.refreshCache()

        result



    getAuthor: =>*
        { context, db } = @getContext context, db
        yield models.User.getById @createdById, {}, db



    getView: (name) =>*
        extensions = yield extensionLoader.load yield @getTypeDefinition()
        model = yield extensions.getModel()
        yield model.view.call @, name

exports.Post = Post
