async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').markedb
models = require './'
postModule = require('./post')

class Article extends postModule.Post

    @_getMeta: ->
        userModule = require('./user')
        meta = {
            fields: {
                stub: { type: 'string', required: false },
                state: { type: 'string', validate: -> ['draft','published'].indexOf(@state) isnt -1 },
                title: 'string',
                cover: { type: 'string', required: false },
                smallCover: { type: 'string', required: false, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: 'false' },
                format: { type: 'string', validate: -> ['markdown'].indexOf(@format) isnt -1 },
                rating: 'number',
                recommendations: { type: 'array', contents: userModule.User.Summary, validate: -> user.validate() for user in @recommendations },                                
                publishedAt: { type: 'number', required: false, validate: -> not (@state is 'published' and not @publishedAt) }
            }
        }
        meta = @mergeMeta meta, postModule.Post._getMeta()
        
        
        
    constructor: (params) ->
        @type = 'article'
        super
        


    summarize: (view = "standard") =>
        switch view
            when "concise"
                return {
                    type: if @cover then 'image-text' else 'text',
                    image: @smallCover,
                    @title,
                    content: if @format is 'markdown' and @content then mdparser(@content) else 'Invalid format.'
                }

    


exports.Article = Article

