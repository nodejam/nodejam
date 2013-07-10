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
                cover: { type: 'string', required: false },
                smallCover: { type: 'string', required: false, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
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
        


    summarize: (view = "standard") =>
        switch view
            when "standard"
                return {
                    type: if @cover then 'image-text' else 'text',
                    image: @smallCover,
                    @title,
                    content: if @format is 'markdown' and @content then mdparser(@content) else 'Invalid format.'
                }

    


exports.Article = Article

