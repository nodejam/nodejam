BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError
moment = require('../common/moment')

class Message extends BaseModel
    
    ###
        Fields
            - network (string)        
            - userid (string)
            - type (string; global-notification, user-notification)
            - reason (string; new-user, new-post etc)
            - data (object, depends on reason). We don't validate this.
    ###

    
    @_meta: {
        type: Message,
        collection: 'messages',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        logging: {
            isLogged: true,
            onInsert: 'NEW_MESSAGE'
        }
    }
    
    
    constructor: (params) ->
        @priority ?= 'normal'
        super
        
        
    
    save: (context, cb) =>
        super
        

    
    format: (_format) =>
        try
            switch _format
                when 'timeline'
                    switch @reason
                        when 'new-collection'
                            user = @data.collection.createdBy
                            {                        
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: if user.domain is 'tw' then "/@#{user.username}" else "/#{user.domain}/#{user.username}"
                                },
                                verb: "added a new collection",
                                object: {
                                    thumbnail: @data.collection.icon,
                                    name: @data.collection.name,
                                    link: "/#{@data.collection.stub}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }
                        when 'published-post'
                            user = @data.post.createdBy
                            {
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: if user.domain is 'tw' then "/@#{user.username}" else "/#{user.domain}/#{user.username}"
                                },
                                verb: "published",
                                object: {
                                    name: @data.post.title,
                                    link: "/#{@data.post.collections[0].stub}/#{@data.post.uid}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }                   
        catch error
            return ''                
            
            
    
    validate: =>
        errors = super().errors

        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'     
        
        if not @userid?
            errors.push 'Invalid userid.'
         
         if not @type
            errors.push 'Invalid type.'
                    
        if @type is 'user-notification'
            _errors = Message._models.User.validateSummary(@to)
            if _errors.length
                errors.push 'Invalid to.'
                errors.concat _errors
            
            _errors = Message._models.User.validateSummary(@from)
            if _errors.length
                errors.push 'Invalid from.'
                errors.concat _errors
        
        #We don't care so much about what's in @data; it is based on @reason.
        #If that's messed up, no big deal.
        
        { isValid: errors.length is 0, errors }
        
    
exports.Message = Message
