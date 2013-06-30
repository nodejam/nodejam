async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
Models = require './'
mdparser = require('../common/markdownutil').marked

class Article extends Models.Post

    @_meta:
        (->
            meta = {
                collection: 'articles',
                fields: {
                    stub: { type: 'string', required: false },
                    state: { type: 'string', validate: -> ['draft','published'].indexOf @state },
                    title: 'string',
                    summary: { type: 'string', required: 'false' },            
                    publishedAt: { 
                        type: 'number',
                        validate: -> if @state is 'published' and not @publishedAt then 'Published post must have a publishedAt field.'
                    }
                }
            }
            utils.extend meta, utils.clone(Post._meta)
        )()


exports.Article = Article

