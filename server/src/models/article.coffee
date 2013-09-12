mdparser = require('../common/lib/markdownutil').marked
postModule = require('./post')
utils = require('../common/utils')
Q = require('../common/q')
models = require('./')

class Article extends postModule.Post

    @describeType: @mergeTypeDefinition {
            type: @,
            name: 'article',
            description: 'Article',
            fields: {
                title: { type: 'string', required: false, maxLength: 200 }
                subtitle: { type: 'string', required: false, maxLength: 200 },
                synopsis: { type: 'string', required: false, maxLength: 2000 },
                cover: { type: 'string', required: false, maxLength: 200 },
                smallCover: { type: 'string', required: false, maxLength: 200, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: false, maxLength: 100000 },
                format: { type: 'string', $in: ['markdown'] }
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

