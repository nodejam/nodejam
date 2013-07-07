async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').markedb
BaseModel = require('./basemodel').BaseModel
Post = require('./post').Post

class Article extends Post

    @_getMeta: ->
        meta = {
            fields: {
                stub: { type: 'string', required: false },
                state: { type: 'string', validate: -> ['draft','published'].indexOf @state },
                title: 'string',
                summary: { type: 'string', required: 'false' },            
                publishedAt: { 
                    type: 'number',
                    validate: -> @state is 'published' and not @publishedAt
                }
            }
        }
        utils.extend meta, utils.clone(Post._getMeta())
        
        
        
    constructor: ->
        @type = 'article'
        super


    summarize: =>        
        summary = new Summary {
            id: @_id.toString(),
            @network,
            @uid,
            @title,
            @createdAt,
            @timestamp,        
            @publishedAt,
            @createdBy           
        }
        

    
    class Summary extends BaseModel    
        @_getMeta: ->
            User = require('./user').User
            {
                type: Summary,
                fields: {
                    id: 'string',
                    network: 'string'
                    uid: 'string',
                    title: 'string',
                    createdAt: 'number',
                    timestamp: 'number',
                    publishedAt: 'number',
                    createdBy: User.Summary,
                }
            }


exports.Article = Article

