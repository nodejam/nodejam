moment = require '../lib/moment'
ForaDbModel = require('./foramodel').ForaDbModel
models = require './'

class Message extends ForaDbModel
    
    @typeDefinition: {
        name: "message",
        collection: 'messages',
        schema: {
            type: 'object',        
            properties: {
                userId: { type: 'string' },
                type: { type: 'string', enum: ['message', 'global-notification', 'user-notification'] },
                to: { type: 'object'  },
                from: { type: 'object' },
                data: { type: 'object' },

            },
            links: {
                user: { type: 'user', key: 'userId' }
            },
            required: ['userId', 'type', 'to', 'from', 'data']
        },
        validate: ->*
            errors = []
            errors = if @type is 'user-notification' or @type is 'message' then errors.concat @to.validate()
            errors = if @type is 'user-notification' or @type is 'message' then errors.concat @from.validate()
    }
        
        
    
    format: (_format) =>
        try
            switch _format
                when 'timeline'
                    switch @reason
                        when 'new-forum'
                            user = @data.forum.createdBy
                            {                        
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "added a new forum",
                                object: {
                                    thumbnail: @data.forum.icon,
                                    name: @data.forum.name,
                                    link: "/#{@data.forum.stub}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }
                        when 'published-post'
                            user = @data.post.createdBy
                            {
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "published",
                                object: {
                                    name: @data.post.title,
                                    link: "/#{@data.post.forum.stub}/#{db.getRowId(@data.post)}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }                   
        catch error
            return ''                
            
            
    
exports.Message = Message
