moment = require '../vendor/moment'
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
                        when 'new-app'
                            user = @data.app.createdBy
                            {
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "added a new app",
                                object: {
                                    thumbnail: @data.app.icon,
                                    name: @data.app.name,
                                    link: "/#{@data.app.stub}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }
                        when 'published-record'
                            user = @data.record.createdBy
                            {
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "published",
                                object: {
                                    name: @data.record.title,
                                    link: "/#{@data.record.app.stub}/#{db.getRowId(@data.record)}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }
        catch error
            return ''



exports.Message = Message
