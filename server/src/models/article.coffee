async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').marked
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


exports.Article = Article

