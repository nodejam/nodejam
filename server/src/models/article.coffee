mdparser = require('../common/lib/markdownutil').marked
postModule = require('./post')
utils = require('../common/utils')
Q = require('../common/q')
models = require('./')

class Article extends postModule.Post

    @describeType: {
            type: @,
            inherits: postModule.Post,
            name: 'article',
            description: 'Article',
            fields: {
                title: { type: 'string', required: false, maxLength: 200 }
                subtitle: { type: 'string', required: false, maxLength: 200 },
                synopsis: { type: 'string', required: false, maxLength: 2000 },
                cover: { type: 'string', required: false, maxLength: 200 },
                smallCover: { type: 'string', required: false, maxLength: 200, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
                content: { type: 'string', required: false, maxLength: 100000 },
                format: { type: 'string', $in: ['markdown'], default: 'markdown' }
            },
            stub: 'title',
            formattedFields: [
                { field: 'content', format: 'format' }
            ]
        }



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
                    content: @formatData(@data, @format),
                    @createdBy,
                    @forum,
                    id: @_id.toString(),
                    @stub
                }



exports.Article = Article

