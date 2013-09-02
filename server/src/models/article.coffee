async = require '../common/async'
utils = require '../common/utils'
mdparser = require('../common/markdownutil').marked
postModule = require('./post')
Q = require('../common/q')

class Article extends postModule.Post

    @describeModel: -> 
        models = @getModels()
        description = {
            type: Article,
            fields: {
                cover: { type: 'string', required: false },
                smallCover: { type: 'string', required: false, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: 'false' },
                format: { type: 'string', validate: -> ['markdown'].indexOf(@format) isnt -1 },                
            }
        }
        @mergeModelDescription description, models.Post.describeModel()
        
        
        
    constructor: (params) ->
        super
        @type ?= 'article'
        


    getView: (name = "standard") =>
        switch name
            when "snapshot"
                {
                    image: @smallCover,
                    @title,
                    @createdBy,
                    id: @_id.toString(),
                    @stub
                } 
            when "card"
                {
                    image: @smallCover,
                    @title,
                    content: @formatContent(),
                    @createdBy,
                    @forum,
                    id: @_id.toString(),
                    @stub
                }

    
    
    formatContent: =>   
        if @format is 'markdown'
            if @content then mdparser(@content) 
        else
            'Invalid format.'


exports.Article = Article

