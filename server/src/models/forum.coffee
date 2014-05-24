thunkify = require 'thunkify'
models = require('./')
conf = require '../conf'

ForumBase = require './forum-base'

class Forum extends ForumBase

    save: (context, db) =>*
        { context, db } = @getContext context, db
        
        #if stub is a reserved name, change it
        if conf.reservedNames.indexOf(@stub) > -1
            throw new Error "Stub cannot be #{@stub}, it is reserved"
        
            regex = '[a-z][a-z0-9|-]*'
            if not regex.text @stub
                throw new Error "Stub is invalid"
        
        if not db.getRowId(@)
            @stats = new Stats {
                posts: 0,
                members: 1,
                lastPost: 0
            }
            @cache ?= { posts: [] }
        
        yield super(context, db)



    summarize: (context, db) =>
        summary = new Summary {
            id: db.getRowId(@),
            network: @network,
            name: @name,
            stub: @stub,
            createdBy: @createdBy
        }



    getView: (name, context, db) =>*
        switch name
            when 'card'
                {
                    id: db.getRowId(@)
                    @network,
                    @name,
                    @description,
                    @stub,
                    @createdBy,
                    @cache,
                    image: @cover?.image?.small
                }



    join: (user, token, context, db) =>*
        { context, db } = @getContext context, db
        if @access is 'public'
            yield @addRole user, 'member', context, db
        else
            throw new Error "Access denied"



    addPost: (post, context, db) =>*
        { context, db } = @getContext context, db
        post.forumId = db.getRowId(@)
        post.forum = @summarize context, db
        yield post.save context, db
        


    getPost: (stub, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Post.get({ 'forumId': db.getRowId(@), stub }, {}, db)
        


    getPosts: (limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Post.find({ 'forumId': db.getRowId(@), state: 'published' },  { sort, limit }, context, db)
        

    
    addRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db
        
        membership = yield models.Membership.get { 'forumId': db.getRowId(@), 'user.username': user.username }, context, db
        if not membership
            membership = new (models.Membership) {
                forumId: db.getRowId(@),
                forum: @summarize(context, db),
                userId: user.id,
                user,
                roles: [role]
            }
        else
            if membership.roles.indexOf(role) is -1 
                membership.roles.push role
        yield membership.save context, db   
                


    removeRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db
        membership = yield models.Membership.get { 'forumId': db.getRowId(@), 'user.username': user.username }, context, db
        membership.roles = (r for r in membership.roles when r isnt role)
        yield if membership.roles.length then membership.save() else membership.destroy()
                


    getMembership: (username, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Membership.get { 'forum.id': db.getRowId(@), 'user.username': username }, {}, db
        
    
                                
    getMemberships: (roles, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Membership.find { 'forumId': db.getRowId(@), roles: { $in: roles } }, { sort: { id: -1 }, limit: 200 }, context, db
        
      
            
    refreshCache: (context, db) =>*
        { context, db } = @getContext context, db
        posts = yield @getPosts 10, db.setRowId({}, -1), context, db
        @cache = { posts: [] }

        if posts.length 
            for p in posts
                @cache.posts.push yield p.getView("concise", context, db)

            @stats.posts = yield models.Post.count({ 'forumId': db.getRowId(@) , state: 'published' }, context, db)
            @stats.lastPost = posts[0].savedAt
            yield @save context, db

module.exports = Forum

