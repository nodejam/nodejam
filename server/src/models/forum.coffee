ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel
utils = require('../lib/utils')
models = require('./')

class Forum extends ForaDbModel

    class Settings extends ForaModel

        @typeDefinition: {
            type: @,
            alias: "Forum.Settings",
            fields: {
                commentsEnabled: 'boolean !required',
                commentsOpened: 'boolean !required',
            }
        }

    @Settings: Settings

    class Summary extends ForaModel   
        @typeDefinition: {
            type: @,
            alias: "Forum.Summary",
            fields: {
                id: 'string',
                network: 'string',
                name: 'string',
                stub: 'string',
                createdBy: "User.Summary" 
            }
        }    

    @Summary: Summary

    class Stats extends ForaModel   
        @typeDefinition: {
            type: @,
            alias: "Forum.Stats",
            fields: {
                posts: 'number',
                members: 'number',
                lastPost: 'number'
            }
        }
        
    @Stats: Stats

    @childModels: { Stats, Summary, Settings }

    @typeDefinition: -> {
        type: @,
        alias: 'Forum',
        collection: 'forums',
        fields: {
            network: 'string',
            name: 'string',
            stub: 'string',
            description: 'string',
            type: { type: 'string', $in: ['public', 'protected', 'private'] },
            postTypes: { type: 'array', contents: 'string', map: { format: 'csv' } },
            settings: "Forum.Settings !required",
            cover: 'Cover !required',
            createdBy: "User.Summary",
            snapshot: '',            
            stats: "Forum.Stats",
            createdAt: { autoGenerated: true, event: 'created' },
            updatedAt: { autoGenerated: true, event: 'updated' }
        },
        associations: {
            info: { type: "ForumInfo", key: { '_id': 'forumid' } }
        },
        logging: {
                onInsert: 'NEW_FORUM'
        }
    }
        
    
    save: (context, db) =>        
        if not @_id
            @stats = new Stats {
                posts: 0,
                members: 1,
                lastPost: 0
            }
            @postTypes ?= ['Article']
            @snapshot ?= { posts: [] }
        
        super


        
    summarize: =>        
        summary = new Summary {
            id: @_id.toString()
            network: @network,
            name: @name,
            stub: @stub,
            createdBy: @createdBy
        }
        
        
        
    getView: (name) =>
        switch name
            when 'card'
                {
                    id: @_id.toString()
                    @network,
                    @name,
                    @description,
                    @stub,
                    @createdBy,
                    @snapshot,
                    image: @cover.image?.small
                }



    join: (user, token, context, db) =>*
        { context, db } = @getContext context, db
        if @type is 'public'
            yield @addRole user, 'member', context, db
        else
            throw new Error "Access denied"
        
        
        
    addPost: (post, context, db) =>*
        { context, db } = @getContext context, db
        post.forum = @summarize()
        yield post.save context, db
        


    getPosts: (limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Post.find({ 'forum.stub': @stub, 'forum.network': @network, state: 'published' }, ((cursor) -> cursor.sort(sort).limit limit), context, db)
        

    
    addRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db
        
        membership = yield models.Membership.get { 'forum.id': @_id.toString(), 'user.username': user.username }, context, db
        if not membership
            membership = new (models.Membership) {
                forum: @summarize(),
                user: user,
                roles: [role]
            }
        else
            if membership.roles.indexOf(role) is -1 
                membership.roles.push role
        yield membership.save context, db   
                


    removeRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db
        
        membership = yield models.Membership.get { 'forum.id': @_id.toString(), 'user.username': user.username }, context, db
        membership.roles = (r for r in membership.roles when r isnt role)
        yield if membership.roles.length then membership.save() else membership.destroy()
                
    
                                
    getMemberships: (roles, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Membership.find { 'forum.id': @_id.toString(), roles: { $in: roles } }, ((cursor) -> cursor.sort({ id: -1 }).limit 200), context, db
        
      
            
    refreshSnapshot: (context, db) =>*
        { context, db } = @getContext context, db
        posts = yield models.Post.find({ 'forum.id': @_id.toString() , state: 'published' }, ((cursor) -> cursor.sort({ _id: -1 }).limit 10), context, db)            
        @snapshot = { posts: (p.getView("snapshot") for p in posts) }
        if posts.length
            cursor = yield models.Post.getCursor({ 'forum.id': @_id.toString() , state: 'published' }, context, db)
            @stats.posts = yield thunkify(cursor.count).call cursor
            @stats.lastPost = posts[0].savedAt
            yield @save context, db


exports.Forum = Forum

