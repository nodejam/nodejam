mdparser = require('../common/lib/markdownutil').marked
postModule = require('./post')
utils = require('../common/utils')
Q = require('../common/q')
models = require('./')

class Article extends postModule.Post

    @describeType: @mergeTypeDefinition {
            type: @,
            fields: {
                cover: { type: 'string', required: false },
                smallCover: { type: 'string', required: false, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: 'false' },
                format: { type: 'string', validate: -> ['markdown'].indexOf(@format) isnt -1 },                
            }
        }, models.Post.describeType

        
        
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

