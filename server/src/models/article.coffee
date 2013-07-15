async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').marked
postModule = require('./post')

class Article extends postModule.Post

    @describeModel: -> 
        models = @getModels()
        description = {
            type: Article,
            fields: {
                stub: { type: 'string', required: false },
                state: { type: 'string', validate: -> ['draft','published'].indexOf(@state) isnt -1 },
                title: 'string',
                cover: { type: 'string', required: false },
                smallCover: { type: 'string', required: false, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: 'false' },
                format: { type: 'string', validate: -> ['markdown'].indexOf(@format) isnt -1 },
                rating: 'number',
                recommendations: { type: 'array', contents: models.User.Summary, validate: -> user.validate() for user in @recommendations },                                
                publishedAt: { type: 'number', required: false, validate: -> not (@state is 'published' and not @publishedAt) }
            }
        }
        @mergeModelDescription description, models.Post.describeModel()
        
        
        
    constructor: (params) ->
        @type = 'article'
        super
        


    summarize: (view = "standard") =>
        switch view
            when "concise"
                return {
                    image: @smallCover,
                    @title,
                    content: if @format is 'markdown' and @content then mdparser(@content) else 'Invalid format.',
                    @createdBy,
                    @forum,
                    @_id
                }

    


exports.Article = Article

