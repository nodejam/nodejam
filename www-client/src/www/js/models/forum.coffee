
ForumBase = require('./forum-base').ForumBase

class Forum extends ForumBase

    @typeDefinition: ->
        typeDef = ForumBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* Forum.getTypeUtils().getTypeDefinition(obj.type)
            if def.ctor isnt Forum
                throw new Error "Forum type definitions must have ctor set to Forum"
            def
        typeDef


    getTypeDefinition: =>*
        typeUtils = Forum.getTypeUtils()
        yield* typeUtils.getTypeDefinition(@type)



exports.Forum = Forum
