async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').markedb
BaseModel = require('./basemodel').BaseModel
postModule = require('./post')

class Article extends postModule.Post

    @_getMeta: ->
        meta = {
            fields: {
                stub: { type: 'string', required: false },
                state: { type: 'string', validate: -> ['draft','published'].indexOf(@state) isnt -1 },
                title: 'string',
                summary: { type: 'string', required: 'false' },            
                content: { type: 'string', required: 'false' },
                format: { type: 'string', validate: -> ['markdown'].indexOf(@format) isnt -1 },
                publishedAt: { 
                    type: 'number',
                    validate: -> @state is 'published' and not @publishedAt
                }
            }
        }
        @mergeMeta meta, postModule.Post._getMeta()
        
        
        
    constructor: ->
        @type = 'article'
        super
        


    summarize: =>        
        summary = new Summary {
            id: @_id.toString(),
            @uid,
            @title,
            @createdAt,
            @timestamp,        
            @publishedAt,
            @createdBy           
        }
        

    
    class Summary extends BaseModel    
        @_getMeta: ->
            userModule = require('./user')
            {
                type: Summary,
                fields: {
                    id: 'string',
                    uid: 'string',
                    title: 'string',
                    createdAt: 'number',
                    timestamp: 'number',
                    publishedAt: 'number',
                    createdBy: userModule.User.Summary,
                }
            }


exports.Article = Article

