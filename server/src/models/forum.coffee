BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class Forum extends BaseModel

    ###
        Fields
            - network (string)        
            - name (string)
            - stub (string)
            - type (string)
            - settings (string)            
            - icon
            - iconThumbnail
            - cover
            - createdBy (summarized user)
            - moderators (array of summarized user)
            - totalItems (integer))
            - totalSubscribers (integer) 
    ###    
        
    @_meta: {
        type: Forum,
        forum: 'forums',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },        
        logging: {
            isLogged: true,
            onInsert: 'NEW_FORUM'
        }
    }
    
    

    constructor: (params) ->
        @totalItems ?= 0
        @totalSubscribers ?= 0
        @settings = {}
        @moderators = []
        super
        

    
    save: (context, cb) =>
        super



    summarize: (fields = []) =>
        fields = fields.concat ['name', 'stub', 'type', 'createdBy', 'network']
        result = super fields
        result.id = @_id.toString()
        result        



    @validateSummary: (forum) =>
        errors = []
        if not forum
            errors.push "Invalid forum."
        
        required = ['id', 'name', 'stub', 'type', 'createdBy', 'network']
        for field in required
            if not forum[field]
                errors.push "Invalid #{field}"

        _errors = Forum._models.User.validateSummary(forum.createdBy)
        if _errors.length            
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
                
        errors
                
    

    validate: =>
        errors = super().errors
        
        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'        
        
        if not @name
            errors.push 'Invalid name.'

        if not @stub
            errors.push 'Invalid stub.'

        if not @type or ['post', 'event', 'user', 'poll', 'forum', 'image', 'file'].indexOf(@type) is -1
            errors.push 'Invalid type.'
        
        if not @settings
            errors.push "Invalid settings."

        if not @icon
            errors.push 'Invalid icon.'
           
        if not @iconThumbnail
            errors.push 'Invalid iconThumbnail.'
            
        if not @cover
            errors.push 'Invalid cover.'
            
        _errors = Forum._models.User.validateSummary(@createdBy)
        if _errors.length            
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors

        if @moderators.length < 1
            errors.push 'There should be at least one moderator.'
        else
            for mod in @moderators
                _errors = Forum._models.User.validateSummary(mod)
                if _errors.length 
                    errors.push 'Invalid moderator.'
                    errors = errors.concat _errors

        switch @type
            when 'post'
                _errors = Forum._models.Post.validateForumSnapshot(@)
                if _errors.length            
                    errors.push 'Invalid snapshot.'
                    errors = errors.concat _errors
        
        if isNaN(@totalItems)
            errors.push 'Invalid totalItems.'

        if isNaN(@totalSubscribers)
            errors.push 'Invalid totalSubscribers.'
        
        { isValid: errors.length is 0, errors }
    
    
    
exports.Forum = Forum
