async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
BaseModel = require('./basemodel').BaseModel
mdparser = require('../common/markdownutil').marked


class Post extends BaseModel

    ###
        Fields
            - network (string)        
            - uid (random unique id)
            - stub (string, eg: 'funny-monsters')
            - forum (name of the forum to which this belongs)
            - state (string; 'draft' or 'published')
            - createdBy (summarized user)
            - title (string; exists if type is 'free-verse')
            - recommendations
            - meta (array of string)
            - rating (integer)
            - summary
            - publishedAt (integer)
        }
    ###      
    
    @_meta: {
        type: Post,
        forum: 'posts',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        concurrency: 'optimistic',
        logging: {
            isLogged: true,
            onInsert: 'NEW_POST'
        }
    }

    

    @search: (criteria, settings, context, cb) =>
        limit = @getLimit settings.limit, 100, 1000
                
        params = {}
        for k, v of criteria
            params[k] = v
        
        Post.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, cb        
        
        
    
    constructor: (params) ->
        @forums ?= []
        @recommendations ?= []
        @meta ?= []
        @tags ?= []
        @rating ?= 1
        @createdAt = Date.now()
        super
        
        
    
    save: (context, cb) =>
        if not @_id 
            @uid ?= utils.uniqueId()

        #If there is a stub, check if a post with the same stub already exists.
        if @stub
            Post.get { @stub }, {}, (err, post) =>
                if not post
                    super
                else
                    cb new AppError "Stub already exists", "STUB_EXISTS"
        else
            super



    summarize: (fields = []) =>
        fields = fields.concat ['uid', 'title', 'createdAt', 'timestamp', 'publishedAt', 'createdBy', 'network']
        result = super fields
        result.id = @_id.toString()
        result         
        

    
    createView: (type) =>
        switch type
            when 'summary', 'full'
                {
                    type: 'post',
                    summary: {
                        title: @summary.title,
                        text: if @summary.text then mdparser(@summary.text),
                        image: @summary.image
                    },
                    @uid,
                    @createdBy,
                    @forums,
                    @title,
                    content: if @content then mdparser(@content),
                    @cover
                }            

        
    
    @refreshForumSnapshot: (post, context, cb) =>
        for forum in post.forums
            @_models.Forum.get { stub: forum.stub }, {}, (err, forum) =>
                @search { "forums.stub": forum.stub, state: 'published' }, { sort: { publishedAt: -1 }, limit: 4 }, {}, (err, posts) =>
                    @getCursor { "forums.stub": forum.stub, state: 'published' }, context, (err, cursor) =>
                        cursor.count (err, count) =>
                            forum.snapshot = {
                                recentPosts: (p.summarize() for p in posts),
                            }
                            forum.totalItems = count
                            forum.lastRefreshedAt = if posts[0] then posts[0].publishedAt else 0                            
                            forum.save context, cb                        



    @validateForumSnapshot: (forum) =>
        errors = []
        
        if forum.snapshot        
            for item in forum.snapshot.recentPosts
                _errors = Post.validateSummary item
                if _errors.length
                    errors = errors.concat _errors
                    
                if isNaN forum.totalItems
                    errors.push "snapshot.totalPosts should be a number."
                
                if isNaN forum.lastRefreshedAt
                    errors.push "snapshot.lastRefreshedAt should be a number."
        
        errors    
        

    @validateSummary: (post) =>
        errors = []
        
        if not post
            errors.push "Invalid post."
        
        required = ['id', 'uid', 'title', 'createdAt', 'timestamp', 'publishedAt', 'createdBy']
        for field in required
            if not post[field]
                errors.push "Invalid #{field}"

        _errors = Post._models.User.validateSummary(post.createdBy)
        if _errors.length            
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
                
        errors


    validate: =>
        errors = super().errors
        
        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'      
        
        if not @uid
            errors.push 'Invalid stub.'

        if not @forums.length
            errors.push 'Post should belong to at least one forum.'

        for forum in @forums
            _errors = Post._models.Forum.validateSummary(forum)
            if _errors.length                 
                errors.push "Invalid forum."
                errors = errors.concat _errors 

        if not @state or (@state isnt 'published' and @state isnt 'draft')
            errors.push 'Invalid state.'

        _errors = Post._models.User.validateSummary(@createdBy)
        if _errors.length            
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
            
        for user in @recommendations
            _errors = Post._models.User.validateSummary(user)
            if _errors.length                 
                errors.push "Invalid recommendation."
                errors = errors.concat _errors            

        if isNaN(@rating)
            errors.push 'Rating must be a number.'

        if @publishedAt and isNaN(@publishedAt)
            errors.push 'PublishedAt must be a number.'

        if @state is 'published'
            if not @summary.title
                errors.push 'Invalid summary title.'
            if not @summary.text
                errors.push 'Invalid summary text.'
        
        { isValid: errors.length is 0, errors }

exports.Post = Post
