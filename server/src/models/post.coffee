React = require 'react'
utils = require '../lib/utils'
models = require './'
widgets = require '../common/widgets'
ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

class Post extends ForaDbModel

    @builtinExtensionCache = {}
    
    @typeDefinition: ->
        {
            name: "post",
            collection: 'posts',
            discriminator: (obj) ->*
                def = yield Post.getTypeUtils().getTypeDefinition(obj.type)
                if def.ctor isnt Post                    
                    throw new Error "Post type definitions must have ctor set to Post"
                def
            schema: {
                type: 'object',        
                properties: {
                    type: { type: 'string' },
                    forumId: { type: 'string' },
                    forum: { $ref: 'forum-summary' },
                    createdById: { type: 'string' },
                    createdBy: { $ref: 'user-summary' },
                    meta: { type: 'array', items: { type: 'string' } },
                    tags: { type: 'array', items: { type: 'string' } },
                    stub: { type: 'string' },
                    recommendations: { type: 'array', items: { $ref: 'user-summary' } },            
                    state: { type: 'string', enum: ['draft','published'] },
                    savedAt: { type: 'integer' }
                },
                required: ['type', 'forumId', 'forum', 'createdById', 'createdBy', 'meta', 'tags', 'stub', 'recommendations', 'state', 'savedAt']
            },
            indexes: [
                { 'state': 1, 'forum.stub': 1 },
                { 'state': 1, 'forumId': 1 },
                { 'state': 1, 'createdAt': 1, 'forum.stub': 1 }, 
                { 'createdById' : 1 },
                { 'createdBy.username': 1 }
            ],
            links: {
                forum: { type: 'forum', key: 'forumId' }
            }
            autoGenerated: {
                createdAt: { event: 'created' },
                updatedAt: { event: 'updated' }
            },            
            trackChanges: true,
            logging: {
                onInsert: 'NEW_POST'
            }
        }


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
        
    
    
    @create: (params) ->*
        typeDef = yield (yield @getTypeDefinition()).discriminator params
        post = new Post params
        post.getTypeDefinition = ->*
            typeDef
        post


    
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
        
        extensions = yield Post.getExtensions yield @getTypeDefinition()
        yield extensions.model.save.call @

        #If the stub has changed, we need to check if it's unique
        @stub ?= utils.uniqueId(16)

        result = yield super(context, db)
        
        if @state is 'published'
            forum = yield models.Forum.getById @forumId, context, db
            yield forum.refreshCache()
        
        result



    getView: (name) =>*
        extensions = yield Post.getExtensions yield @getTypeDefinition()
        yield extensions.model.view.call @, name
                


    @render: (template, { post, forum, author, layout }) =>*        
        extensions = yield Post.getExtensions yield post.getTypeDefinition()
        component = extensions.templates[template] { post, forum, author, layout }
        React.renderComponentToString component
        

        
    @getExtensions: (typeDef) =>*
        switch typeDef.extensionType
            when 'builtin'
                if not @builtinExtensionCache[typeDef.name]
                    @builtinExtensionCache[typeDef.name] = {
                        model: require("../type-definitions/posts/#{typeDef.name}/model"),
                        templates: {
                            card: require("../type-definitions/posts/#{typeDef.name}/cardtemplate"),
                            item: require("../type-definitions/posts/#{typeDef.name}/itemtemplate")
                        }
                    }
                @builtinExtensionCache[typeDef.name]
            else
                throw new Error "Unsupported extension type"

    
exports.Post = Post
